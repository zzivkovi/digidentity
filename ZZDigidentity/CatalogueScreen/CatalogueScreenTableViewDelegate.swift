//
//  CatalogueScreenTableViewDelegate.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

// MARK:-

protocol CatalogueScreenTableViewDelegateType {
    var tableView: UITableView { get set }
    func reloadTableView()
}

// MARK:-

class CatalogueScreenTableViewDelegate: NSObject {

    private let dataLoadDelay = 1.0

    var tableView: UITableView = UITableView() {
        didSet {
            self.dataSource.delegate = self

            tableView.dataSource = self
            tableView.delegate = self
            self.reloadTableData()
        }
    }

    private var controller: UIViewController
    private var dataSource: CatalogueScreenDataSourceType

    init(controller: UIViewController, itemsDataSource: ItemsDataSourceType) {
        self.controller = controller
        self.dataSource = CatalogueScreenDataSource(itemsDataSource: itemsDataSource)
    }
}

// MARK:- CatalogueScreenTableViewDelegateType

extension CatalogueScreenTableViewDelegate: CatalogueScreenTableViewDelegateType {
    func reloadTableView() {
        self.reloadTableData()
    }
}

// MARK:-

extension CatalogueScreenTableViewDelegate {

    private func reloadTableData() {
        self.tableView.reloadData()

        if self.scrollToLoadingItem() {
            return
        }

        // Find first row with data
        let first = self.dataSource.items.filter {
            switch $0 {
            case .item(_):
                return true
            default:
                return false
            }
        }.first
        // Scroll to first row with data
        if let firstItem = first, let index = self.dataSource.items.firstIndex(of: firstItem) {
            self.tableView.scrollToRow(at: .init(row: index, section: 0) , at: .top, animated: false)
        }
    }

    private func scrollToLoadingItem() -> Bool {
        // Find first row with loading state
        let first = self.dataSource.items.filter {
            switch $0 {
            case .loading(_):
                return true
            default:
                return false
            }
            }.first
        // Scroll to first row with data
        if let firstItem = first, let index = self.dataSource.items.firstIndex(of: firstItem) {
            self.tableView.scrollToRow(at: .init(row: index, section: 0) , at: .top, animated: true)
            return true
        }
        return false
    }

    @objc private func loadOlderData() {
        self.dataSource.loadItems(type: .older)
    }

    @objc private func loadNewerData() {
        self.dataSource.loadItems(type: .newer)
    }
}

// MARK:- UITableViewDataSource

extension CatalogueScreenTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.dataSource.items.count else {
            return UITableViewCell(frame: .zero)
        }

        let cell: UITableViewCell?
        let itemCase = self.dataSource.items[indexPath.row]

        switch itemCase {
        case .item(let item):
            let itemCell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier) as? ItemTableViewCell
            itemCell?.setApiItem(item)
            cell = itemCell

        case .loading(_):
            let loaderCell = tableView.dequeueReusableCell(withIdentifier: LoaderCell.reuseIdentifier) as? LoaderCell
            loaderCell?.animate()
            cell = loaderCell

        case .deleting(_):
            let loaderCell = tableView.dequeueReusableCell(withIdentifier: LoaderCell.reuseIdentifier) as? LoaderCell
            loaderCell?.animate()
            cell = loaderCell

        case .notLoaded(_):
            let loaderCell = tableView.dequeueReusableCell(withIdentifier: LoaderCell.reuseIdentifier) as? LoaderCell
            loaderCell?.animate(with: .wait(duration: self.dataLoadDelay))
            cell = loaderCell
            
        case .end:
            cell = tableView.dequeueReusableCell(withIdentifier: EndCell.reuseIdentifier)
        }

        return cell ?? UITableViewCell(frame: .zero)
    }
}

// MARK:- UITableViewDelegate

extension CatalogueScreenTableViewDelegate: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            self.perform(#selector(loadNewerData),  with: nil, afterDelay: self.dataLoadDelay)
        } else if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height {
            self.perform(#selector(loadOlderData),  with: nil, afterDelay: self.dataLoadDelay)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
}

// MARK:- CatalogueScreenDataSourceDelegate

extension CatalogueScreenTableViewDelegate: CatalogueScreenDataSourceDelegate {
    func itemsUpdated(in catalogueDataSource: CatalogueScreenDataSourceType) {
        self.reloadTableData()
    }

    func receivedError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.controller.present(alert, animated: true, completion: nil)
    }
}
