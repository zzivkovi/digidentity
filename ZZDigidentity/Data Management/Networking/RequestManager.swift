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

    init(networkingManager: NetworkManagerType) {
        self.networkingManager = networkingManager
    }
}

extension RequestMangerType {

}
