//
//  APIItem.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

struct APIItem {
    let id: String
    let text: String
    let confidence: Float
    let imageString: String

    func image() -> UIImage? {
        guard let data = self.imageString.data(using: .utf8) else {
            return nil
        }
        let image = UIImage(data: data)
        return image
    }
}

extension APIItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case confidence
        case imageString = "img"
    }
}
