//
//  CatalogueScreenViewController.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

protocol CatalogueDependencies {
    var requestManager: RequestManagerType { get }
}

class CatalogueScreenViewController: UIViewController {

    static func create(with dependencies: CatalogueDependencies) -> CatalogueScreenViewController {
        let controller = CatalogueScreenViewController()
        controller.requestManager = dependencies.requestManager
        return controller
    }

    private var requestManager: RequestManagerType!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loadDataTapped() {
        self.requestManager.getItems(after: nil) { (result) in
            switch result {
            case .success(let items):
                print("Success: \(items)")
            case .failure(_):
                print("Failed")
            }
        }
    }
}
