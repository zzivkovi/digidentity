//
//  ItemsDataSource.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 08/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

enum FetchType {
    case newer
    case older
}

protocol ItemDataSourceDelegate {
    func itemsUpdated(in itemDataSource: ItemsDataSourceType)
    func receivedError(error: Error)
}

protocol ItemsDataSourceType {
    var items: [APIItem] { get }
    var delegate: ItemDataSourceDelegate? { get set }
    func loadItems(type: FetchType)
}

class ItemsDataSource {

    private var requestManager: RequestManagerType
    private var itemsCache: ItemsDiskStorageType

    var delegate: ItemDataSourceDelegate?
    var items = [APIItem]()

    init(requestManager: RequestManagerType, itemsCache: ItemsDiskStorageType) {
        self.requestManager = requestManager
        self.itemsCache = itemsCache

        if let items = self.itemsCache.loadItems() {
            self.handleItems(items)
        }
    }
}

extension ItemsDataSource: ItemsDataSourceType {

    func loadItems(type: FetchType) {
        // On empty list load initial items
        if self.items.isEmpty {
            self.loadInitialItems()
            return
        }

        // Later or earlier
        switch type {
        case .older:
            self.loadOlderItems()
        case .newer:
            self.loadNewerItems()
        }
    }
}

extension ItemsDataSource {
    private func loadInitialItems() {
        self.requestManager.getItems(with: .initial) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(result)
        }
    }

    private func loadNewerItems() {
        guard let first = self.items.first else {
            return
        }

        self.requestManager.getItems(with: .newer(itemId: first.id)) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(result)
        }
    }

    private func loadOlderItems() {
        guard let last = self.items.last else {
            return
        }

        self.requestManager.getItems(with: .older(itemId: last.id)) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<[APIItem]>) {
        switch result {
        case .success(let items):
            self.handleItems(items)
        case .failure(let error):
            self.delegate?.receivedError(error: error)
        }
    }

    private func handleItems(_ items: [APIItem]) {
        // If there are items, sort and replace current list
        if !items.isEmpty {
            self.items = items.sorted(by: { (i1, i2) -> Bool in i1.id > i2.id })
            self.itemsCache.cacheItems(self.items)
        }
        // Notify delegate about finished data load
        self.delegate?.itemsUpdated(in: self)
    }
}
