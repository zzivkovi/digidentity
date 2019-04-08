//
//  ItemsDataSource.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 08/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

enum ItemDataSourceError: Error {
    case alreadyLoading
}

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
    private var itemsCache: ItemsCacheType
    private var isLoading: Bool = false {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.isLoading
        }
    }

    var delegate: ItemDataSourceDelegate?
    var items = [APIItem]()

    init(requestManager: RequestManagerType, itemsCache: ItemsCacheType) {
        self.requestManager = requestManager
        self.itemsCache = itemsCache

        if let items = self.itemsCache.loadItems() {
            self.handleItems(items)
        }
    }
}

extension ItemsDataSource: ItemsDataSourceType {

    func loadItems(type: FetchType) {
        // Check if already loading
        guard !self.isLoading else {
            self.delegate?.receivedError(error: ItemDataSourceError.alreadyLoading)
            return
        }

        // Empty list
        guard !self.items.isEmpty else {
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
        self.isLoading = true
        self.requestManager.getInitialItems { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(result)
        }
    }

    private func loadNewerItems() {
        guard let first = self.items.first else {
            return
        }

        self.isLoading = true
        self.requestManager.getItemsNewerThan(itemId: first.id) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(result)
        }
    }

    private func loadOlderItems() {
        guard let last = self.items.last else {
            return
        }

        self.isLoading = true
        self.requestManager.getItemsOlderThan(itemId: last.id) { [weak self] (result) in
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
            self.isLoading = false
        }
    }

    private func handleItems(_ items: [APIItem]) {

        if !items.isEmpty {
            self.items = items.sorted(by: { (i1, i2) -> Bool in i1.id > i2.id })
            self.itemsCache.cacheItems(self.items)
        }
        self.delegate?.itemsUpdated(in: self)
        self.isLoading = false
    }
}
