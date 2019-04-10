//
//  CatalogueScreenViewController.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

class CatalogueScreenViewController: UIViewController {

    static func create() -> CatalogueScreenViewController {
        guard let controller = UIStoryboard(name: String(describing: self), bundle: nil).instantiateViewController(withIdentifier: String(describing: self)) as? CatalogueScreenViewController else {
            assertionFailure("Mising controller")
            return CatalogueScreenViewController()
        }
        controller.tableViewDelegate = CatalogueScreenTableViewDelegate(controller: controller,
                                                                        itemsDataSource: Dependencies.shared.itemsDataSource)
        return controller
    }

    @IBOutlet var tableView: UITableView!

    private var tableViewDelegate: CatalogueScreenTableViewDelegateType!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableViewDelegate.tableView = self.tableView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableViewDelegate.reloadTableView()
    }
}
