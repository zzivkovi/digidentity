//
//  NetworkError.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case general(Error)
    case invalidResponse(Int)
}
