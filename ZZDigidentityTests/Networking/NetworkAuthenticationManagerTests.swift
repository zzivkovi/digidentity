//
//  NetworkAuthenticationManagerTests.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class NetworkAuthenticationManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_itemsRequestParameters() {
        // Given
        let sut = NetworkAuthenticationManager()

        // When
        let itemsRequestHeaderParis = sut.itemsRequestHeaderPairs

        // Then
        XCTAssertEqual(itemsRequestHeaderParis.count, 3)
    }
}
