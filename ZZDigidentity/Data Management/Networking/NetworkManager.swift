//
//  NetworkManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import Foundation

enum NetworkResult {
    case data(Data)
    case failure(NetworkError)
}

protocol NetworkManagerType {
    func loadData(from url: URL, completionHandler: @escaping (NetworkResult) -> Void)
}

struct NetworkManager {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }
}

extension NetworkManager: NetworkManagerType {
    func loadData(from url: URL, completionHandler: @escaping (NetworkResult) -> Void) {
        let task = self.session.dataTask(with: url) { data, response, error in
            let result: NetworkResult

            if let error = error {
                // Error
                result = .failure(NetworkError.general(error))
            } else if let data = data {
                // Data
                result = .data(data)
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
