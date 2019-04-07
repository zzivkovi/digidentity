//
//  NetworkAuthenticationManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol NetworkAuthenticationManagerType {
    var defaultRequestHeaderParis: [String: String] { get }
}

private enum RequestTypes: String {
    case all
}

struct NetworkAuthenticationManager {

    private let headerValues: [RequestTypes: [String: String]]

    init() {
        self.headerValues = [RequestTypes.all: ["1": "d69b387f7cd10f9e6d28fb9b4a1caf5f",
                                                "2": "df49b6cd51b0baf6e98f373e2efd8d23",
                                                "3": "e09f00e06f34c579743c06c2f36092fa"]]
    }
}

extension NetworkAuthenticationManager: NetworkAuthenticationManagerType {
    var defaultRequestHeaderParis: [String : String] {
        return self.headerValues[RequestTypes.all] ?? [:]
    }
}
