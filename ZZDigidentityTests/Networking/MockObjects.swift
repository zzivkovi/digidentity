//
//  URLSessionMock.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation
@testable import ZZDigidentity

// MARK:- Error
enum TestError: Error {
    case general
}

// MARK:- URLSession mocks

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    var data: Data?
    var response: URLResponse?
    var error: Error?

    var request: URLRequest?


    override func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let response = self.response
        let error = self.error

        self.request = request

        return URLSessionDataTaskMock {
            completionHandler(data, response, error)
        }
    }
}

// MARK:- NetworkAuthentication

class NetworkAuthenticationManagerMock: NetworkAuthenticationManagerType {

    var itemsRequestHeader: [String : String]?

    var defaultRequestHeaderParis: [String : String] {
        return itemsRequestHeader ?? [:]
    }

    
}
