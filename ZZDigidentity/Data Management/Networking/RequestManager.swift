//
//  RequestManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

enum ItemsFetchRequestType {
    case initial
    case older(itemId: String)
    case newer(itemId: String)
}

protocol RequestManagerType {
    func getItems(with fetchType: ItemsFetchRequestType, completionHandler: @escaping (Result<[APIItem]>) -> Void)
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
    func getItems(with fetchType: ItemsFetchRequestType, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        // Get the appropriate URL
        let tempUrl: URL?
        switch fetchType {
        case .initial:
            tempUrl = self.urlBuilder.initialItems()
        case .older(let itemId):
            tempUrl = self.urlBuilder.itemsOlderThan(itemId: itemId)
        case .newer(let itemId):
            tempUrl = self.urlBuilder.itemsNewerThan(itemId: itemId)
        }

        // Make sure URL exists
        guard let url = tempUrl else {
            completionHandler(.failure(NetworkError.invalidUrl))
            return
        }
        // Fetch data
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
