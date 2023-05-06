//
//  NetworkResource.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/25.
//

import Foundation

struct NetworkResource<T: Decodable> {
    var baseUrl: String
    var params: [String: String]
    var headers: [String: String]
    var urlRequest: URLRequest? {
        var urlComponents = URLComponents(string: baseUrl)!
        let queryItems = params.map { (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        }
        urlComponents.queryItems = queryItems
        var request = URLRequest(url: urlComponents.url!)
        headers.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    init(baseUrl: String, params: [String: String] = [:], headers: [String: String] = [:]) {
        self.baseUrl = baseUrl
        self.params = params
        self.headers = headers
    }
}
