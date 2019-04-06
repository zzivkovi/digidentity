//
//  NetworkManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol NetworkManagerType {

}

struct NetworkManager {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }
}

extension NetworkManager: NetworkManagerType {

}


