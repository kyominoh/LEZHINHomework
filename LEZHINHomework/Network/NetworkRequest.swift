//
//  NetworkRequest.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation

protocol NetworkRequest {
    var url: String { get }
    var params: [URLQueryItem]? { get }
    var header: [String: String]? { get }
}

public struct NetworkWorker {
    static func request<T: Decodable>(_ req: NetworkRequest, method: String? = "GET") async throws -> T {
        guard var components = URLComponents(string: Kakao.baseUrl.rawValue) else { throw SearchError.urlError }
        components.queryItems = req.params
        guard let url = components.url else { throw SearchError.paramError }
        var request = URLRequest(url: url) 
        request.httpMethod = method
        req.header?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {        
            throw SearchError.responseError
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }   
}
