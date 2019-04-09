//
//  Log.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 09/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

struct Log {
    static func debug(_ message: @autoclosure () -> String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        print("\(String(describing: file))\n\(line): \(function)\n\(message())")
    }

    static func message(_ message: @autoclosure () -> String) {
        print(message())
    }
}
