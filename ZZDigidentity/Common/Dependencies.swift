//
//  Dependencies.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

struct Dependencies {
    static let shared = Dependencies()

    private let urlBuilder: URLBuilderType
    private let sessionValidator: URLSessionCertificateValidatorType
    private let urlSession: URLSession
    private let networkAuthenticationManager: NetworkAuthenticationManagerType
    private let networkManager: NetworkManagerType
    
    let requestManager: RequestManagerType

    init() {
        self.urlBuilder = URLBuilder()
        self.sessionValidator = URLSessionCertificateValidator(domain: self.urlBuilder.domain)
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self.sessionValidator, delegateQueue: nil)
        self.networkAuthenticationManager = NetworkAuthenticationManager()
        self.networkManager = NetworkManager(session: self.urlSession, authenticationManager: self.networkAuthenticationManager)
        self.requestManager = RequestManager(networkingManager: self.networkManager, urlBuilder: self.urlBuilder)
    }
}

extension Dependencies: CatalogueScreenDataSourceDependencies {
    // Implemented in class body
}
