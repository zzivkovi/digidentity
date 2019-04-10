//
//  LoaderCell.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

enum LoaderCellAction {
    case wait(duration: TimeInterval)
    case delete
    case load
}

class LoaderCell: UITableViewCell, Reusable {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    func animate(with action: LoaderCellAction = .load) {
        self.activityIndicator.transform = CGAffineTransform.identity

        switch action {
        case .wait(let duration):
            self.wait(duration: duration)
        case .load:
            self.activityIndicator.color = .green
        case .delete:
            self.activityIndicator.color = .red
        }

        self.activityIndicator.startAnimating()
    }

    private func wait(duration: TimeInterval) {
        self.activityIndicator.color = .black
        self.activityIndicator.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: duration) {
            self.activityIndicator.transform = CGAffineTransform.identity
        }
    }

    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
}
