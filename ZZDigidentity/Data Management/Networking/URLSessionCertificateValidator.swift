//
//  URLSessionCertificateValidator.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol URLSessionCertificateValidatorType: URLSessionDelegate {

}

class URLSessionCertificateValidator: NSObject {

    private let domain: String
    private let certificateValidator: TLSValidator = TLSValidator()

    init(certificates: [String] = ["certificate.cer"], domain: String) {
        self.domain = domain
        self.certificateValidator.pinnedCertificates = certificates
    }
}

extension URLSessionCertificateValidator: URLSessionCertificateValidatorType {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // Challenge must contain trust
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Ignoring invalid trust certificates
        var secresult = SecTrustResultType.invalid
        if SecTrustEvaluate(trust, &secresult) != errSecSuccess {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Ignoring certificates which are not present in the bundle
        if !self.isCertificatePinned(trust: trust) {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        // Success
        let credential = URLCredential(trust: trust)
        completionHandler(.useCredential, credential)
    }
}

extension URLSessionCertificateValidator {
    func isCertificatePinned(trust: SecTrust) -> Bool {
        return self.certificateValidator.evaluateServerTrust(trust, forDomain: self.domain)
    }
}
