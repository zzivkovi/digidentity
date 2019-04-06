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

    private let urlBuilder: URLBuilder
    private let urlSession: URLSession
    private let networkManager: NetworkManagerType
    
    let requestManager: RequestManagerType

    init() {
        self.urlBuilder = URLBuilder()
        self.urlSession = URLSession.shared
        self.networkManager = NetworkManager(session: self.urlSession)
        self.requestManager = RequestManager(networkingManager: self.networkManager, urlBuilder: self.urlBuilder)
    }
}
