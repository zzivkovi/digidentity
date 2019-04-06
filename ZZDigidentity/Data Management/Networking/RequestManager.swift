//
//  RequestManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol RequestMangerType {
    func getItems(before itemId: String, completionHandler: @escaping (Result<[String]>) -> Void)
}

struct RequestManager {

    let networkingManager: NetworkManagerType
    let urlBuilder: URLBuilder

    init(networkingManager: NetworkManagerType, urlBuilder: URLBuilder = URLBuilder()) {
        self.networkingManager = networkingManager
        self.urlBuilder = urlBuilder
    }
}

extension RequestManager: RequestMangerType {
    func getItems(before itemId: String, completionHandler: @escaping (Result<[String]>) -> Void) {
        guard let url = self.urlBuilder.itemsBefore(itemId: itemId) else {
            completionHandler(.failure(NetworkError.invalidUrl))
            return
        }

        self.networkingManager.loadData(from: url) { (result) in
            switch result {
            case .success(let data):
                let items = self.parseItems(data)
                completionHandler(.success(items))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}

extension RequestManager {
    private func parseItems(_ data: Data) -> [String] {
        return []
    }
}
