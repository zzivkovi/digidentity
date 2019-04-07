//
//  LoaderCell.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

class LoaderCell: UITableViewCell {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    func animate() {
        self.activityIndicator.color = .green
        self.activityIndicator.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicator.color = .black
        self.activityIndicator.stopAnimating()
    }
}
