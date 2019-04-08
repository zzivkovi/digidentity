//
//  NetworkAuthenticationManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol NetworkAuthenticationManagerType {
    var defaultRequestHeaderPairs: [String: String] { get }
}

private enum RequestTypes: String {
    case all
}

struct NetworkAuthenticationManager {

    private let headerValues: [RequestTypes: [String: String]]

    init() {
        self.headerValues = [RequestTypes.all: ["Authorization": "df49b6cd51b0baf6e98f373e2efd8d23"]]
    }
}

extension NetworkAuthenticationManager: NetworkAuthenticationManagerType {
    var defaultRequestHeaderPairs: [String : String] {
        return self.headerValues[RequestTypes.all] ?? [:]
    }
}
