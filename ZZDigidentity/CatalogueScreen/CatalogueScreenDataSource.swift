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
    case notLoaded(APIItem)
    case loading(APIItem)
    case deleting(APIItem)
    case end
    case item(APIItem)

    var isAction: Bool {
        switch self {
        case .loading(_), .deleting(_):
            return true
        default:
            return false
        }
    }

    static func == (lhs: ItemState, rhs: ItemState) -> Bool {
        switch (lhs, rhs) {
        case (let .notLoaded(lhs), let .notLoaded(rhs)):
            return lhs == rhs
        case (let .loading(lhs), let .loading(rhs)):
            return lhs == rhs
        case (.end, .end):
            return true
        case (let .item(lhs), let .item(rhs)):
            return lhs == rhs
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
    func loadItems(type: FetchType)

    var items:[ItemState] { get }
    var delegate: CatalogueScreenDataSourceDelegate? { get set }
}

// MARK:- Private methods

class CatalogueScreenDataSource {

    private var itemsDataSource: ItemsDataSourceType

    var delegate: CatalogueScreenDataSourceDelegate?
    var items = [ItemState]()

    init(itemsDataSource: ItemsDataSourceType) {
        self.itemsDataSource = itemsDataSource
        self.itemsDataSource.delegate = self

        // Get and transform items from ItemsDataSource
        self.items = self.itemsDataSource.items.compactMap { .item($0) }
        self.handleItems(self.itemsDataSource.items)

        // Load items if list is empty
        if self.itemsDataSource.items.isEmpty {
            let itemId = self.itemsDataSource.loadItems(type: .newer)
            self.updateLoadingState(for: itemId)
        }
    }

    private func canLoad(type: FetchType) -> Bool {
        // Not if already executing an action
        let actions = self.items.filter { $0.isAction }
        if !actions.isEmpty {
            return false
        }

        // Not if should fetch newer and first item is the end of data
        if case .newer = type, let firstState = self.items.first, .end == firstState {
            return false
        }

        // Not if should fetch older and last item is the end of data
        if case .older = type, let lastState = self.items.last, .end == lastState {
            return false
        }

        return true
    }
}

// MARK:-

extension CatalogueScreenDataSource: CatalogueScreenDataSourceType {

    func loadItems(type: FetchType) {
        guard self.canLoad(type: type) else {
            return
        }
        
        let itemId = self.itemsDataSource.loadItems(type: type)
        self.updateLoadingState(for: itemId)
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

    /// Maps `APIItem` array to own `ListItem` array and notifies the delegate
    private func handleItems(_ items: [APIItem]) {
        self.items = self.mapItemsToItemStates(items)
        self.delegate?.itemsUpdated(in: self)
    }

    /// Creates an array of displayable `ItemState` objects from an `APIItem` array
    private func mapItemsToItemStates(_ items: [APIItem]) -> [ItemState] {
        // No items
        if let temp = handleEmptyList(items) {
            return temp
        }

        var newItems = [ItemState]()
        // Generate first item
        if let first = items.first, let currentFirst = self.items.first {
            newItems.append(self.listItem(for: first, andPreviousItemState: currentFirst))
        }

        // Actual items
        newItems += items.compactMap { .item($0) }

        // Generate last item
        if let last = items.last, let currentLast = self.items.last {
            newItems.append(self.listItem(for: last, andPreviousItemState: currentLast))
        }

        return newItems
    }

    /// Displays a dummy `loading` item state in case of an empty list
    private func handleEmptyList(_ items: [APIItem]) -> [ItemState]? {
        if !items.isEmpty {
            return nil
        }
        return [.loading(APIItem.emptyItem())]
    }

    /// Returns `notLoaded` state for an item or `end` if the item for previous list and the new one are the same
    private func listItem(for item: APIItem, andPreviousItemState current: ItemState) -> ItemState {

        // Was loading an item and new item is the same
        if case let .loading(currentItem) = current, currentItem.id == item.id {
            return .end
        }

        return .notLoaded(item)
    }

    /// Finds `notLoaded` state for item and replaces it with `loading`
    private func updateLoadingState(for itemId: String?) {
        guard let itemId = itemId else {
            return
        }

        let loadingStateItem = self.items.filter {
            switch $0 {
            case .notLoaded(let item):
                return item.id == itemId
            default:
                return false
            }
        }.first
        guard let loadingState = loadingStateItem, case let .notLoaded(item)? = loadingStateItem, let index = self.items.firstIndex(of: loadingState) else {
            return
        }

        self.items[index] = .loading(item)
        self.delegate?.itemsUpdated(in: self)
    }
}
