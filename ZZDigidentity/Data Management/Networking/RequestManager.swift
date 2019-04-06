//
//  RequestManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol RequestMangerType {

}

struct RequestManager {

    let networkingManager: NetworkManagerType
    let urlBuilder: URLBuilder

    init(networkingManager: NetworkManagerType, urlBuilder: URLBuilder = URLBuilder()) {
        self.networkingManager = networkingManager
        self.urlBuilder = urlBuilder
    }
}

extension RequestMangerType {

}
