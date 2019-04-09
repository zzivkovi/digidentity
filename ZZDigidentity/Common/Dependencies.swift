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
    private let requestManager: RequestManagerType

    let itemsCache: ItemsDiskStorageType
    let itemsDataSource: ItemsDataSourceType

    init() {
        self.itemsCache = ItemsDiskStorage(password: "ifune98ffkdndjn9hu%$&")
        self.urlBuilder = URLBuilder()
        self.sessionValidator = URLSessionCertificateValidator(domain: self.urlBuilder.domain)
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self.sessionValidator, delegateQueue: nil)
        self.networkAuthenticationManager = NetworkAuthenticationManager()
        self.networkManager = NetworkManager(session: self.urlSession, authenticationManager: self.networkAuthenticationManager)
        self.requestManager = RequestManager(networkingManager: self.networkManager, urlBuilder: self.urlBuilder)
        self.itemsDataSource = ItemsDataSource(requestManager: self.requestManager, itemsCache: self.itemsCache)
    }
}
