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
        static let itemsComponent = "items"
        static let afterParameterName = "since_id"
        static let beforeParameterName = "maxId"
    }
}

protocol URLBuilderType {
    var domain: String { get }
    func itemsAfter(itemId: String?) -> URL?
    func itemsBefore(itemId: String) -> URL?
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

    func itemsAfter(itemId: String?) -> URL? {
        let parameters: [String: String]?
        if let itemId = itemId {
            parameters = [RequestParameters.Items.afterParameterName: itemId]
        } else {
            parameters = nil
        }
        return self.url(with: RequestParameters.Items.itemsComponent, parameters: parameters)
    }

    func itemsBefore(itemId: String) -> URL? {
        let parameters = [RequestParameters.Items.beforeParameterName: itemId]
        return self.url(with: RequestParameters.Items.itemsComponent, parameters: parameters)
    }
}

extension URLBuilder {

    private func url(with subPath: String, parameters: [String: String]?) -> URL? {
        var components = URLComponents(string: self.baseUrl + subPath)
        if let parameters = parameters {
            components?.queryItems = parameters.compactMap { URLQueryItem(name: $0, value: $1) }
        }
        return components?.url
    }
}
