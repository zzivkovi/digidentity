//
//  URLBuilderTests.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class URLBuilderTests: XCTestCase {
    let sut = URLBuilder()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_customBaseUrl() {
        // Given
        let urlBuilder = URLBuilder(baseUrl: "ftp://base.url:123/dummy/")

        // When
        let url = urlBuilder.itemsNewerThan(itemId: "1")

        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "ftp")
        XCTAssertEqual(url?.port, 123)
    }

    func test_itemsAfter_withoutItemId() {
        // Given
        let itemId: String? = nil

        // When
        let url = sut.itemsNewerThan(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsPath) ?? false)
        XCTAssertFalse(url?.absoluteString.contains("?") ?? true)
        XCTAssertFalse(url?.absoluteString.contains(RequestParameters.Items.newerThanParameterName) ?? true)
    }

    func test_itemsAfter_itemId() {
        // Given
        let itemId = "item123"

        // When
        let url = sut.itemsNewerThan(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsPath) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(RequestParameters.Items.newerThanParameterName) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(itemId) ?? false)
    }

    func test_itemsBefore() {
        // Given
        let itemId = "item321"

        // When
        let url = sut.itemsOlderThan(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsPath) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(RequestParameters.Items.olderThanParameterName) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(itemId) ?? false)
    }
}
