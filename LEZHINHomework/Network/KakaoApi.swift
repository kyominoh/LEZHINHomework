//
//  KakaoApi.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation

enum Kakao: String {
    case REST_API_KEY = "d6b158efceefb8f138e705e217969141"
    case baseUrl = "https://dapi.kakao.com/v2/search/image"
}

enum KakaoApiRequest: NetworkRequest {
    case imageSearch(query: String, page: Int, size: Int, sort: SearchSort)
    
    var url: String {
        switch self {
        case .imageSearch:
            return Kakao.baseUrl.rawValue
        }
    }
    
    var params: [URLQueryItem]? {
        switch self {
        case .imageSearch(let query, let page, let size, let sort):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sort", value: sort.rawValue),
                URLQueryItem(name: "size", value: "\(String(size))")
            ]
        }
    }

    var header: [String : String]? {
        ["Authorization": "KakaoAK \(Kakao.REST_API_KEY.rawValue)"]
    }
}
