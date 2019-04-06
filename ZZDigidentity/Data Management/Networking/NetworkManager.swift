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

            // Check for valid status code
            if let error = self.checkResponseForValidity(response) {
                completionHandler(.failure(error))
                return
            }

            // Must have data
            guard let data = data else {
                let resultError: Error
                if let error = error {
                    resultError = NetworkError.general(error)
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    resultError = NetworkError.missingData(statusCode)
                }
                completionHandler(.failure(resultError))
                return
            }

            // Return data
            completionHandler(.success(data))
        }

        task.resume()
    }
}

extension NetworkManager {
    private func checkResponseForValidity(_ response: URLResponse?) -> Error? {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard 200..<300 ~= statusCode else {
            return NetworkError.httpError(statusCode)
        }
        return nil
    }
}
