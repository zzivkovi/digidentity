//
//  RequestManagerTests.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class RequestManagerTests: XCTestCase {
    var urlBuilder = URLBuilderMock()
    var networkManager = NetworkManagerMock()
    var sut: RequestManager!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        urlBuilder.url = URL(string: "https://dummy.url/")
        networkManager.result = nil
        sut = RequestManager(networkingManager: networkManager, urlBuilder: urlBuilder)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_initialItems_invalidUrl() {
        // Given
        urlBuilder.url = nil
        networkManager.result = Result.success("data".data(using: .utf8)!)
        let expectation = XCTestExpectation(description: "Invalid URL")

        // When
        sut.getInitialItems { (result) in
            switch result {
            case .failure(let error):
                if case NetworkError.invalidUrl = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_initialItems_failure() {
        // Given
        networkManager.result = .failure(TestError.general)
        let expectation = XCTestExpectation(description: "Failure result")

        // When
        sut.getInitialItems { (result) in
            switch result {
            case .failure(let error):
                if case TestError.general = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_initialItems_emptyData() {
        // Given
        networkManager.result = .success(Data())
        let expectation = XCTestExpectation(description: "Empty data")

        // When
        sut.getInitialItems { (result) in
            switch result {
            case .success(let items):
                expectation.fulfill()
                XCTAssertTrue(items.isEmpty)
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_initialItems_correctData() {
        // Given
        let data = "[{\"img\": \"werwet\",\"text\": \"Hello world!\",\"confidence\": 0.7,\"_id\":\"123\"}]".data(using: .utf8) ?? Data()
        networkManager.result = .success(data)
        let expectation = XCTestExpectation(description: "Existing item")

        // When
        sut.getInitialItems { (result) in
            switch result {
            case .success(let items):
                expectation.fulfill()
                XCTAssertEqual(items.count, 1)
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }


    func test_itemsBefore_invalidUrl() {
        // Given
        urlBuilder.url = nil
        networkManager.result = Result.success("data".data(using: .utf8)!)
        let expectation = XCTestExpectation(description: "Invalid URL")

        // When
        sut.getItemsOlderThan(before: "itemId") { (result) in
            switch result {
            case .failure(let error):
                if case NetworkError.invalidUrl = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_itemsBefore_failure() {
        // Given
        networkManager.result = .failure(TestError.general)
        let expectation = XCTestExpectation(description: "Failure result")

        // When
        sut.getItemsOlderThan(before: "itemId") { (result) in
            switch result {
            case .failure(let error):
                if case TestError.general = error {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_itemsBefore_emptyData() {
        // Given
        networkManager.result = .success(Data())
        let expectation = XCTestExpectation(description: "Empty data")

        // When
        sut.getItemsOlderThan(before: "itemId") { (result) in
            switch result {
            case .success(let items):
                expectation.fulfill()
                XCTAssertTrue(items.isEmpty)
            default:
                XCTFail()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}
