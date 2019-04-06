//
//  NetworkManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

protocol NetworkManagerType {
    func loadData(from url: URL, completionHandler: @escaping (Result<Data>) -> Void)
}

struct NetworkManager {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }
}

extension NetworkManager: NetworkManagerType {
    func loadData(from url: URL, completionHandler: @escaping (Result<Data>) -> Void) {
        let task = self.session.dataTask(with: url) { data, response, error in
            let result: Result<Data>

            if let error = error {
                // Error
                result = .failure(NetworkError.general(error))
            } else if let data = data {
                // Data
                result = .success(data)
            } else {
                // Missing data
                let responseCode: Int
                if let response = response as? HTTPURLResponse {
                    responseCode = response.statusCode
                } else {
                    responseCode = -1
                }
                result = .failure(NetworkError.invalidResponse(responseCode))
            }

            completionHandler(result)
        }

        task.resume()
    }
}
