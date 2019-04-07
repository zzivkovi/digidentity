//
//  TLSValidator.m
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

#import "TLSValidator.h"
#import <AssertMacros.h>

/**
 *  get public key from the cert data
 */
static id ZZPublicKeyFromCertificate(NSData *certificateData)
{
    SecCertificateRef certificate = nil;
    id publicKey = nil;
    SecPolicyRef policy = nil;
    SecTrustRef allowedTrust = nil;
    SecTrustResultType result = kSecTrustResultInvalid;

    certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
    __Require_Quiet(certificate != NULL, _out);

    policy = SecPolicyCreateBasicX509();
    __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificate, policy, &allowedTrust), _out);
    __Require_noErr_Quiet(SecTrustEvaluate(allowedTrust, &result), _out);

    publicKey = (__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust);

_out:

    if (allowedTrust) {
        CFRelease(allowedTrust);
    }

    if (policy) {
        CFRelease(policy);
    }

    if (certificate) {
        CFRelease(certificate);
    }

    return publicKey;
}

/**
 *  evaluates the X.509 certificate trust
 */
static BOOL ZZServerTrustIsValid(SecTrustRef serverTrust)
{
    SecTrustResultType result = kSecTrustResultInvalid;
    OSStatus evalStatus = SecTrustEvaluate(serverTrust, &result);

    return evalStatus == errSecSuccess && (result == kSecTrustResultUnspecified      // The OS trusts this certificate implicitly.
                                           || result == kSecTrustResultProceed);    // The user explicitly told the OS to trust it.
}

/**
 *  Creates the array of public keys from the X.509 certificate trust
 */
static NSArray * ZZPublicKeyTrustChainFromServerTrust(SecTrustRef serverTrust)
{
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];

    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);

        SecCertificateRef someCertificates[] = { certificate };
        CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);

        SecTrustRef trust;
        __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificates, policy, &trust), _out);

        SecTrustResultType result;
        __Require_noErr_Quiet(SecTrustEvaluate(trust, &result), _out);

        [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];

    _out:

        if (trust) {
            CFRelease(trust);
        }

        if (certificates) {
            CFRelease(certificates);
        }

        continue;
    }

    CFRelease(policy);

    return [NSArray arrayWithArray:trustChain];
}

/**
 *  Whether or not public keys are equal
 */
static BOOL ZZSecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2)
{
    return [(__bridge id)key1 isEqual:(__bridge id)key2];
}

@interface TLSValidator ()
@property (nonatomic, copy) NSArray *pinnedPublicKeys;
@end

@implementation TLSValidator

@synthesize allowSelfSignedCertificates = _allowSelfSignedCertificates, pinnedCertificates = _pinnedCertificates;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    // 0. Return no for nil as params
    NSAssert(serverTrust != nil, @"Failed because of nil instead of server trust");
    NSAssert(domain != nil, @"Failed because of nil insteed of domain");

    if (serverTrust == nil) {
        return NO;
    }

    if (domain == nil) {
        return NO;
    }

    // 1. Create a policy object for evaluating SSL certificate chain & host name if specified
    id policy = (__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain);
    OSStatus setPoliciesStatus = SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)@[policy]);

    NSAssert(setPoliciesStatus == errSecSuccess, @"Failed to set the policies to use in an evaluation.");

    if (setPoliciesStatus != errSecSuccess) {
        return NO;
    }

    // 2. There are no custom anchor certificates to trust...
    OSStatus trustAnchorCertificatesStatus = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[]);
    NSAssert(trustAnchorCertificatesStatus == errSecSuccess, @"Failed to set trusted anchor certificates");

    if (trustAnchorCertificatesStatus != errSecSuccess) {
        return NO;
    }

    // 3. the built-in anchor certificates are trusted only.
    OSStatus trustBuiltinCertificatesStatus = SecTrustSetAnchorCertificatesOnly(serverTrust, false);
    NSAssert(trustBuiltinCertificatesStatus == errSecSuccess, @"Failed to reenable trusting built-in anchor certificates");

    if (trustBuiltinCertificatesStatus != errSecSuccess) {
        return NO;
    }

    // 4. Evaluate the trust policy if we don't allow invalid certificates
    if (!self.allowSelfSignedCertificates && !ZZServerTrustIsValid(serverTrust)) {
        return NO;
    }

    // 5. Insure we have public keys for pinning
    if (self.pinnedPublicKeys.count == 0) {
        return YES;
    }

    // 5. Get public keys from the cert chain
    NSUInteger trustedPublicKeyCount = 0;
    NSArray *publicKeys = ZZPublicKeyTrustChainFromServerTrust(serverTrust);

    // 5. Check that there is at least one valid public key in the chain
    for (id trustChainPublicKey in publicKeys) {
        for (id pinnedPublicKey in self.pinnedPublicKeys) {
            if (ZZSecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
                trustedPublicKeyCount += 1;
            }
        }
    }

    return trustedPublicKeyCount > 0;
}

#pragma mark - Private

- (void)setPinnedCertificates:(NSArray<NSString *> *)pinnedCertificates
{
    _pinnedCertificates = [pinnedCertificates copy];
    _pinnedPublicKeys = [self loadPublicKeys];
}

- (NSArray<NSData *> *)loadPublicKeys
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSMutableArray *pinnedPublicKeys = [NSMutableArray array];

    for (NSString *filename in self.pinnedCertificates) {
        NSString *path = [bundle pathForResource:filename ofType:nil];
        NSData *certificate = [NSData dataWithContentsOfFile:path];

        if (!certificate) {
            continue;
        }

        id publicKey = ZZPublicKeyFromCertificate(certificate);

        if (!publicKey) {
            continue;
        }

        [pinnedPublicKeys addObject:publicKey];
    }

    return pinnedPublicKeys;
}

@end
