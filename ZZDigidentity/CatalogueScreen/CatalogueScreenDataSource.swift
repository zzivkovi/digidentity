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
    func loadLaterItems()
    func loadEarlierItems()

    var items:[ItemState] { get }
    var delegate: CatalogueScreenDataSourceDelegate? { get set }
}

// MARK:- Implementation

class CatalogueScreenDataSource {

    private var isLoading: Bool = false
    let requestManager: RequestManagerType
    let itemsCache: ItemsCacheType

    var delegate: CatalogueScreenDataSourceDelegate?
    var items = [ItemState]()

    init(requestManager: RequestManagerType, itemsCache: ItemsCacheType) {
        self.requestManager = requestManager
        self.itemsCache = itemsCache

        if let items = itemsCache.loadItems() {
            self.loadedItems(items)
        } else {
            self.loadInitialItems()
        }
    }
}

// MARK:- CatalogueScreenDataSourceType

extension CatalogueScreenDataSource: CatalogueScreenDataSourceType {

    func loadLaterItems() {
        guard !items.isEmpty else {
            self.loadInitialItems()
            return
        }

        // Do not load if already loading
        guard let itemId = self.canLoad(item: self.items.last) else {
            return
        }

        self.requestManager.getItems(after: itemId) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(let error):
                strongSelf.handleError(error)
            case .success(let items):
                strongSelf.cacheLoadedItems(items)
                strongSelf.loadedItems(items)
            }
        }
    }

    func loadEarlierItems() {
        guard !items.isEmpty else {
            self.loadInitialItems()
            return
        }
        
        // Do not load if already loading
        guard let itemId = self.canLoad(item: self.items.first) else {
            return
        }

        self.requestManager.getItems(before: itemId) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(let error):
                strongSelf.handleError(error)
            case .success(let items):
                strongSelf.cacheLoadedItems(items)
                strongSelf.loadedItems(items)
            }
        }
    }
}

// MARK:- Private methods

extension CatalogueScreenDataSource {

    func loadInitialItems() {
        self.requestManager.getItems(after: nil) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(let error):
                strongSelf.handleError(error)
            case .success(let items):
                strongSelf.cacheLoadedItems(items)
                strongSelf.loadedItems(items)
            }
        }
    }

    private func handleError(_ error: Error) {
        self.handleErrorResult()
        self.reportErrorToDelegate(error)
    }

    private func canLoad(item: ItemState?) -> String? {
        // Do not load if already loading earlier or later
        if let first = self.items.first, case .loading = first {
            return nil
        } else if let last = self.items.last, case .loading = last {
            return nil
        }

        // Check that the item is actually notLoaded
        guard let item = item, case .notLoaded(let itemId) = item else {
            return nil
        }

        // Replace .notLoaded(_) with .loading(_)
        if let index = self.items.index(where: { $0 == item }) {
            items[index] = .loading(itemId: itemId)
            self.reportSuccessToDelegate()
        }

        return itemId
    }

    private func cacheLoadedItems(_ items: [APIItem]) {
        self.itemsCache.cacheItems(items)
    }

    private func loadedItems(_ items: [APIItem]) {
        // Handle empty results
        guard !items.isEmpty else {
            self.handleEmptyResult()
            return
        }

        guard let first = items.first, let last = items.last else {
            return
        }

        // Handle items
        self.items.removeAll()
        self.items = items.map { .item($0) }
        self.items.insert(.notLoaded(itemId: first.id), at: 0)
        self.items.append(.notLoaded(itemId: last.id))
        self.reportSuccessToDelegate()
    }

    private func handleErrorResult() {
        if let first = self.items.first, case let .loading(itemId) = first {
            self.items.removeFirst()
            self.items.insert(.notLoaded(itemId: itemId), at: 0)
        } else if let last = self.items.last, case let .loading(itemId) = last {
            self.items.removeLast()
            self.items.append(.notLoaded(itemId: itemId))
        }
        self.reportSuccessToDelegate()
    }

    private func handleEmptyResult() {
        if let first = self.items.first, case .loading = first {
            self.items.removeFirst()
            self.items.insert(.end, at: 0)
        } else if let last = self.items.last, case .loading = last {
            self.items.removeLast()
            self.items.append(.end)
        }
        self.reportSuccessToDelegate()
    }

    private func reportSuccessToDelegate() {
        DispatchQueue.main.async {
            self.delegate?.itemsUpdated(in: self)
        }
    }

    private func reportErrorToDelegate(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate?.receivedError(error: error)
        }
    }
}
