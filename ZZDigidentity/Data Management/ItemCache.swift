//
//  ItemCache.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation
import RNCryptor

protocol ItemsCacheType {
    func loadItems() -> [APIItem]?
    func cacheItems(_ items: [APIItem])
}

struct ItemCache {

    let password: String
    let cachePath: URL
    
    init(password: String) {
        self.password = password

        self.cachePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("itemsCache") ?? FileManager.default.temporaryDirectory
    }
}

extension ItemCache: ItemsCacheType {
    func loadItems() -> [APIItem]? {
        guard let data = try? Data(contentsOf: self.cachePath) else {
            return nil
        }

        guard let decryptedData = try? RNCryptor.decrypt(data: data, withPassword: self.password) else {
            return nil
        }

        let items = try? JSONDecoder().decode([APIItem].self, from: decryptedData)
        return items
    }

    func cacheItems(_ items: [APIItem]) {
        guard let data = try? JSONEncoder().encode(items) else {
            return
        }

        let encryptedData = RNCryptor.encrypt(data: data, withPassword: self.password)
        try? encryptedData.write(to: self.cachePath)
    }
}
