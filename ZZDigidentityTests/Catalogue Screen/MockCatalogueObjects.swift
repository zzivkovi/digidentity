//
//  MockObjects.swift
//  ZZDigidentityTests
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import XCTest
@testable import ZZDigidentity

class RequestManagerMock: RequestManagerType {

    var result: Result<[APIItem]>?
    
    func getItems(after itemId: String?, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        if let result = result {
            completionHandler(result)
        }
    }

    func getItems(before itemId: String, completionHandler: @escaping (Result<[APIItem]>) -> Void) {
        if let result = result {
            completionHandler(result)
        }
    }
}

class CatalogueDataSourceDelegateMock: CatalogueScreenDataSourceDelegate {

    var didUpdateItemsClosure: (([ItemState]) -> Void)?
    var didReceiveErrorClosure: ((Error) -> Void)?

    func reset() {
        didUpdateItemsClosure = nil
        didReceiveErrorClosure = nil
    }

    func itemsUpdated(in catalogueDataSource: CatalogueScreenDataSourceType) {
        didUpdateItemsClosure?(catalogueDataSource.items)
    }

    func receivedError(error: Error) {
        didReceiveErrorClosure?(error)
    }
}
