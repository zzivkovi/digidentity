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
    var networkManager: NetworkManagerType!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        networkManager = NetworkManager(session: self.session)
        session.data = nil
        session.response = nil
        session.error = nil
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_failure_onError() {
        // Given
        session.error = TestError.general
        let expectation = XCTestExpectation(description: "Failed data fetch")

        // When
        networkManager.loadData(from: URL(string: "https://test")!) { (result) in
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
        let statusCode = 10
        session.response = HTTPURLResponse(url: URL(string: "https://dummy")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        let expectation = XCTestExpectation(description: "Failed data fetch")

        // When
        networkManager.loadData(from: URL(string: "https://test")!) { (result) in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                if case NetworkError.invalidResponse(let code) = error {
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
        self.session.data = dummyString.data(using: .utf8)
        let expectation = XCTestExpectation(description: "Successful data fetch")

        // When & then
        self.networkManager.loadData(from: URL(string: "https://test")!) { (result) in
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
}
