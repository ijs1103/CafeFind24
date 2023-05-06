//
//  NetworkManager.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/25.
//

import Foundation
import Combine

enum NetworkError: Error {
    case requestError
    case responseError
    case statusCodeError(statusCode: Int)
    case DecodingError(error: Error)
}

final class NetworkService {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    func load<T>(_ resource: NetworkResource<T>) -> AnyPublisher<T, Error> {
        guard let request = resource.urlRequest else {
            return Fail(error: NetworkError.requestError).eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode)
                else {
                    let response = result.response as? HTTPURLResponse
                    let statusCode = response?.statusCode ?? -1
                    throw NetworkError.statusCodeError(statusCode: statusCode)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
