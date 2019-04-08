//
//  URLBuilder.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

struct RequestParameters {
    static let stagingBaseUrl = "https://marlove.net/e/mock/v1/"

    struct Items {
        static let itemsPath = "items"
        static let newerThanParameterName = "since_id"
        static let olderThanParameterName = "maxId"
    }
}

protocol URLBuilderType {
    var domain: String { get }
    func initialItems() -> URL?
    func itemsNewerThan(itemId: String) -> URL?
    func itemsOlderThan(itemId: String) -> URL?
}

struct URLBuilder {
    private let baseUrl: String

    init(baseUrl: String = RequestParameters.stagingBaseUrl) {
        self.baseUrl = baseUrl
    }
}

extension URLBuilder: URLBuilderType {

    var domain: String {
        let url = URL(string: self.baseUrl)
        return url?.host ?? ""
    }

    func initialItems() -> URL? {
        return self.urlWith(path: RequestParameters.Items.itemsPath, parameters: nil)
    }

    func itemsNewerThan(itemId: String) -> URL? {
        let parameters = [RequestParameters.Items.newerThanParameterName: itemId]
        return self.urlWith(path: RequestParameters.Items.itemsPath, parameters: parameters)
    }

    func itemsOlderThan(itemId: String) -> URL? {
        let parameters = [RequestParameters.Items.olderThanParameterName: itemId]
        return self.urlWith(path: RequestParameters.Items.itemsPath, parameters: parameters)
    }
}

extension URLBuilder {

    private func urlWith(path: String, parameters: [String: String]?) -> URL? {
        var components = URLComponents(string: self.baseUrl + path)
        if let parameters = parameters {
            components?.queryItems = parameters.compactMap { URLQueryItem(name: $0, value: $1) }
        }
        return components?.url
    }
}
