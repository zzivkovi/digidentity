//
//  CatalogueScreenTableViewDelegate.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

class CatalogueScreenTableViewDelegate: NSObject {
    var tableView: UITableView = UITableView() {
        didSet {
            self.dataSource.delegate = self

            tableView.dataSource = self
            tableView.delegate = self
            self.reloadData()
        }
    }
    var controller: UIViewController
    private var dataSource: CatalogueScreenDataSourceType

    init(controller: UIViewController, requestManager: RequestManagerType, itemsCache: ItemsCacheType) {
        self.controller = controller
        self.dataSource = CatalogueScreenDataSource(requestManager: requestManager, itemsCache: itemsCache)
    }

    private func reloadData() {
        self.tableView.reloadData()
    }
}

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
            let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as? ItemTableViewCell
            itemCell?.setApiItem(item)
            cell = itemCell

        case .loading(_):
            let loaderCell = tableView.dequeueReusableCell(withIdentifier: "LoaderCell") as? LoaderCell
            loaderCell?.animate()
            cell = loaderCell

        case .notLoaded(_):
            let loaderCell = tableView.dequeueReusableCell(withIdentifier: "LoaderCell") as? LoaderCell
            loaderCell?.stopAnimating()
            cell = loaderCell
            
        case .end:
            cell = tableView.dequeueReusableCell(withIdentifier: "EndCell")
        }

        return cell ?? UITableViewCell(frame: .zero)
    }
}

extension CatalogueScreenTableViewDelegate: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            self.dataSource.loadEarlierItems()
        } else if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height {
            self.dataSource.loadLaterItems()
        }
    }
}

extension CatalogueScreenTableViewDelegate: CatalogueScreenDataSourceDelegate {
    func itemsUpdated(in catalogueDataSource: CatalogueScreenDataSourceType) {
        self.reloadData()
    }

    func receivedError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.controller.present(alert, animated: true, completion: nil)
    }
}
