//
//  TLSValidator.h
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLSValidator : NSObject

@property (nonatomic, assign) BOOL allowSelfSignedCertificates;
@property (nonatomic, copy) NSArray<NSString *> *pinnedCertificates;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
