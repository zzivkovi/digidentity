//
//  CatalogueScreenDataSourceTests.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class CatalogueScreenDataSourceTests: XCTestCase {

    var testItems = [APIItem(id: "id1", text: "-", confidence: 0.1, imageString: "-"),
                     APIItem(id: "id2", text: "-", confidence: 0.1, imageString: "-"),
                     APIItem(id: "id3", text: "-", confidence: 0.1, imageString: "-")]
    var requestManager = RequestManagerMock()
    var delegate = CatalogueDataSourceDelegateMock()
    var sut: CatalogueScreenDataSourceType!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        requestManager.result = nil
        delegate.reset()
        sut = CatalogueScreenDataSource(requestManager: requestManager)
        sut.delegate = delegate
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_initalLoad_empty() {
        // Given, When & Then
        XCTAssertEqual(sut.items.count, 0)
    }

    func test_loadLater_emptyResult() {
        // Given
        requestManager.result = .success(testItems)
        sut.loadEarlierItems()
        requestManager.result = .success([])
        let loadingExpectation = XCTestExpectation(description: ".loading appended to the array end")
        let endExpectation = XCTestExpectation(description: ".end appended to the array end")

        // When
        delegate.didUpdateItemsClosure = { items in
            if let last = items.last, case let .loading(itemId) = last, itemId == "id3" {
                loadingExpectation.fulfill()
            }
            if let last = items.last, case .end = last {
                endExpectation.fulfill()
            }
        }
        sut.loadLaterItems()

        // Then
        wait(for: [loadingExpectation, endExpectation], timeout: 1)
    }

    func test_loadLater_error() {
        // Given
        requestManager.result = .success(testItems)
        sut.loadEarlierItems()
        requestManager.result = .failure(TestError.general)
        let loadingExpectation = XCTestExpectation(description: ".loading appended to the array end")
        let notloadingExpectation = XCTestExpectation(description: ".notLoading appended to the array end")

        // When
        delegate.didUpdateItemsClosure = { items in
            if let last = items.last, case let .loading(itemId) = last, itemId == "id3" {
                loadingExpectation.fulfill()
            }
        }
        delegate.didReceiveErrorClosure = { error in
            if let last = self.sut.items.last, case let .notLoaded(itemId) = last {
                if itemId == "id3" {
                    notloadingExpectation.fulfill()
                }
            }
        }
        sut.loadLaterItems()

        // Then
        wait(for: [loadingExpectation, notloadingExpectation], timeout: 1)
    }

    func test_loadBefore_emptyResult() {
        // Given
        requestManager.result = .success(testItems)
        sut.loadEarlierItems()
        requestManager.result = .success([])
        let loadingExpectation = XCTestExpectation(description: "Loading appended to the end")
        let endExpectation = XCTestExpectation(description: "Load list end")

        // When
        delegate.didUpdateItemsClosure = { items in
            if let last = items.first, case let .loading(itemId) = last, itemId == "id1" {
                loadingExpectation.fulfill()
            }
            if let first = items.first, case .end = first {
                endExpectation.fulfill()
            }
        }
        sut.loadEarlierItems()

        // Then
        wait(for: [loadingExpectation, endExpectation], timeout: 1)
    }

    func test_loadBefore_error() {
        // Given
        requestManager.result = .success(testItems)
        sut.loadEarlierItems()
        requestManager.result = .failure(TestError.general)
        let loadingExpectation = XCTestExpectation(description: ".loading appended to the array end")
        let notloadingExpectation = XCTestExpectation(description: ".notLoading appended to the array end")

        // When
        delegate.didUpdateItemsClosure = { items in
            if let first = items.first, case let .loading(itemId) = first, itemId == "id1" {
                loadingExpectation.fulfill()
            }
        }
        delegate.didReceiveErrorClosure = { error in
            if let first = self.sut.items.first, case let .notLoaded(itemId) = first {
                if itemId == "id1" {
                    notloadingExpectation.fulfill()
                }
            }
        }
        sut.loadEarlierItems()

        // Then
        wait(for: [loadingExpectation, notloadingExpectation], timeout: 1)
    }

}
