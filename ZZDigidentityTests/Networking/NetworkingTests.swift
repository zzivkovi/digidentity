//
//  NetworkingTests.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class NetworkingTests: XCTestCase {
    var session = URLSessionMock()
    var authenticationManager = NetworkAuthenticationManagerMock()
    var networkManager: NetworkManagerType!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        authenticationManager.itemsRequestHeader = nil

        session.data = nil
        session.response = nil
        session.error = nil
        networkManager = NetworkManager(session: self.session, authenticationManager: authenticationManager)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_failure_onError() {
        // Given
        let url = URL(string: "https://test")!
        session.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        session.error = TestError.general
        let expectation = XCTestExpectation(description: "Failed data fetch")

        // When
        networkManager.loadData(from: url) { (result) in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                if case NetworkError.general(_) = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_failure_onMissingData() {
        // Given
        let statusCode = 200
        session.response = HTTPURLResponse(url: URL(string: "https://dummy")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        let expectation = XCTestExpectation(description: "Failed data fetch")

        // When
        networkManager.loadData(from: URL(string: "https://test")!) { (result) in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                if case NetworkError.missingData(let code) = error {
                    expectation.fulfill()
                    XCTAssertEqual(code, statusCode)
                } else {
                    XCTFail()
                }
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_failure_onHttpResponseCode() {
        // Given
        let statusCode = 401
        session.response = HTTPURLResponse(url: URL(string: "https://dummy")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        session.data = "Dummy data".data(using: .utf8)
        let expectation = XCTestExpectation(description: "HTTP status code outside 200 range")

        // When
        networkManager.loadData(from: URL(string: "https://test")!) { (result) in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                if case NetworkError.httpError(let code) = error {
                    expectation.fulfill()
                    XCTAssertEqual(code, statusCode)
                } else {
                    XCTFail()
                }
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_success() {
        // Given
        let dummyString = "dummy string"
        let url = URL(string: "https://test")!
        session.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.data = dummyString.data(using: .utf8)
        let expectation = XCTestExpectation(description: "Successful data fetch")

        // When & then
        self.networkManager.loadData(from: url) { (result) in
            switch result {
            case .success(let data):
                expectation.fulfill()
                XCTAssertEqual(String(data: data, encoding: .utf8), dummyString)
            case .failure(_):
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_headers_inRequest() {
        // Given
        let dummyString = "dummy string"
        let url = URL(string: "https://test")!
        session.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.data = dummyString.data(using: .utf8)
        authenticationManager.itemsRequestHeader = ["key": "value"]

        // When
        networkManager.loadData(from: url) { (_) in }
        let request = session.request

        // Then
        XCTAssertNotNil(request?.allHTTPHeaderFields?["key"])
        XCTAssertEqual(request?.allHTTPHeaderFields?["key"], "value")
    }
}
