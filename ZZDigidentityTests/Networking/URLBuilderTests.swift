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
        let url = urlBuilder.itemsAfter(itemId: "1")

        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "ftp")
        XCTAssertEqual(url?.port, 123)
    }

    func test_itemsAfter_withoutItemId() {
        // Given
        let itemId: String? = nil

        // When
        let url = sut.itemsAfter(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsComponent) ?? false)
        XCTAssertFalse(url?.absoluteString.contains("?") ?? true)
        XCTAssertFalse(url?.absoluteString.contains(RequestParameters.Items.afterParameterName) ?? true)
    }

    func test_itemsAfter_itemId() {
        // Given
        let itemId = "item123"

        // When
        let url = sut.itemsAfter(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsComponent) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(RequestParameters.Items.afterParameterName) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(itemId) ?? false)
    }

    func test_itemsBefore() {
        // Given
        let itemId = "item321"

        // When
        let url = sut.itemsBefore(itemId: itemId)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.contains(RequestParameters.Items.itemsComponent) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(RequestParameters.Items.beforeParameterName) ?? false)
        XCTAssertTrue(url?.absoluteString.contains(itemId) ?? false)
    }
}
