//
//  RequestManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol RequestManagerType {
    func getInitialItems(completionHandler: @escaping (Result<[APIItem]>) -> Void)
    func getItemsNewerThan(itemId: String, completionHandler: @escaping (Result<[APIItem]>) -> Void)
    func getItemsOlderThan(itemId: String, completionHandler: @escaping (Result<[APIItem]>) -> Void)
}

struct RequestManager {

    let networkingManager: NetworkManagerType
    let urlBuilder: URLBuilderType

    init(networkingManager: NetworkManagerType, urlBuilder: URLBuilderType = URLBuilder()) {
        self.networkingManager = networkingManager
        self.urlBuilder = urlBuilder
    }
}

extension RequestManager: RequestManagerType {
    
    func getInitialItems(completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        guard let url = self.urlBuilder.initialItems() else {
            completionHandler(.failure(NetworkError.invalidUrl))
            return
        }
        self.getItems(from: url, completionHandler: completionHandler)
    }

    func getItemsNewerThan(itemId: String, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        guard let url = self.urlBuilder.itemsNewerThan(itemId: itemId) else {
            completionHandler(.failure(NetworkError.invalidUrl))
            return
        }
        self.getItems(from: url, completionHandler: completionHandler)
    }

    func getItemsOlderThan(itemId: String, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        guard let url = self.urlBuilder.itemsOlderThan(itemId: itemId) else {
            completionHandler(.failure(NetworkError.invalidUrl))
            return
        }
        self.getItems(from: url, completionHandler: completionHandler)
    }
}

extension RequestManager {

    private func getItems(from url: URL, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        self.networkingManager.loadData(from: url) { (result) in
            switch result {
            case .success(let data):
                let items = self.parseItems(data)
                DispatchQueue.main.async {
                    completionHandler(.success(items))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }

    private func parseItems(_ data: Data) -> [APIItem] {
        let items = try? JSONDecoder().decode([APIItem].self, from: data)
        return items ?? []
    }
}
