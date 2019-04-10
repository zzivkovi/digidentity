//
//  LoaderCell.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

enum LoaderCellAction {
    case delete
    case load
}

class LoaderCell: UITableViewCell, Reusable {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    func animate(with action: LoaderCellAction = .load) {
        switch action {
        case .load:
            self.activityIndicator.color = .green
        case .delete:
            self.activityIndicator.color = .red
        }
        self.activityIndicator.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicator.color = .black
        self.activityIndicator.stopAnimating()
    }
}
