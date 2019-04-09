//
//  NetworkManager.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 06/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

protocol NetworkManagerType {
    func loadData(from url: URL, completionHandler: @escaping (Result<Data>) -> Void)
}

struct NetworkManager {
    let session: URLSession
    let authenticationManager: NetworkAuthenticationManagerType

    init(session: URLSession, authenticationManager: NetworkAuthenticationManagerType) {
        self.session = session
        self.authenticationManager = authenticationManager
    }
}

extension NetworkManager: NetworkManagerType {

    func loadData(from url: URL, completionHandler: @escaping (Result<Data>) -> Void) {

        var request = URLRequest(url: url)
        let headerPairs = self.authenticationManager.defaultRequestHeaderPairs
        for key in headerPairs.keys {
            request.setValue(headerPairs[key], forHTTPHeaderField: key)
        }

        let task = self.session.dataTask(with: request) { data, response, error in
            Log.message("Finished fetching: \(request.url?.absoluteString ?? "")")

            // Check for error
            if let error = error {
                completionHandler(.failure(NetworkError.general(error)))
                return
            }

            // Check for valid status code
            if let error = self.checkResponseForValidity(response) {
                completionHandler(.failure(error))
                return
            }

            // Must have data
            guard let data = data else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let resultError = NetworkError.missingData(statusCode)
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
