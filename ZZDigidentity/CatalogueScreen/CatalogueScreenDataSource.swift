//
//  CatalogueScreenDataSource.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

// MARK:-

enum ItemState: Equatable {
    case notLoaded(itemId: String)
    case loading(itemId: String)
    case end
    case item(APIItem)

    static func == (lhs: ItemState, rhs: ItemState) -> Bool {
        switch (lhs, rhs) {
        case (let .notLoaded(lhsId), let .notLoaded(rhsId)):
            return lhsId == rhsId
        case (let .loading(lhsId), let .loading(rhsId)):
            return lhsId == rhsId
        case (.end, .end):
            return true
        case (let .item(lhsItem), let .item(rhsItem)):
            return lhsItem == rhsItem
        default:
            return false
        }
    }
}

// MARK:-

protocol CatalogueScreenDataSourceDelegate {
    func itemsUpdated(in catalogueDataSource: CatalogueScreenDataSourceType)
    func receivedError(error: Error)
}

// MARK:-

protocol CatalogueScreenDataSourceType {
    func loadOlderItems()
    func loadNewerItems()

    var items:[ItemState] { get }
    var delegate: CatalogueScreenDataSourceDelegate? { get set }
}

// MARK:-

class CatalogueScreenDataSource {

    private var itemsDataSource: ItemsDataSourceType

    var delegate: CatalogueScreenDataSourceDelegate?
    var items = [ItemState]()

    init(itemsDataSource: ItemsDataSourceType) {
        self.itemsDataSource = itemsDataSource
        self.itemsDataSource.delegate = self

        if self.itemsDataSource.items.isEmpty {
            self.itemsDataSource.loadItems(type: .newer)
        } else {
            self.handleItems(self.itemsDataSource.items)
        }
    }
}

// MARK:-

extension CatalogueScreenDataSource: CatalogueScreenDataSourceType {

    func loadOlderItems() {
        self.itemsDataSource.loadItems(type: .older)
    }

    func loadNewerItems() {
        self.itemsDataSource.loadItems(type: .newer)
    }
}

// MARK:-

extension CatalogueScreenDataSource: ItemDataSourceDelegate {
    func itemsUpdated(in itemDataSource: ItemsDataSourceType) {
        self.handleItems(itemsDataSource.items)
    }

    func receivedError(error: Error) {
        self.delegate?.receivedError(error: error)
    }
}

// MARK:- Private methods

extension CatalogueScreenDataSource {

    private func handleItems(_ items: [APIItem]) {
        self.items = items.compactMap { ItemState.item($0) }
        self.delegate?.itemsUpdated(in: self)
    }
}
