//
//  Reusable.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 09/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
