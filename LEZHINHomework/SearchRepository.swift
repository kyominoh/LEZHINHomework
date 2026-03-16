//
//  SearchRepository.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

private enum Kakao: String {
    case REST_API_KEY = "d6b158efceefb8f138e705e217969141"
    case baseUrl = "https://dapi.kakao.com/v2/search/image"
}

public enum SearchSort: String {
    case accuracy
    case recency
}

public enum SearchError {
    case urlError
    
}


protocol SearchProtocol {
    func search(query: String, page: Int, size: Int, sort: SearchSort) async throws -> KakaoResponse?
}

public struct SearchRepository: Sendable, SearchProtocol {
//    query    String    검색을 원하는 질의어    O
//    sort    String    결과 문서 정렬 방식, accuracy(정확도순) 또는 recency(최신순), 기본 값 accuracy    X
//    page    Integer    결과 페이지 번호, 1~50 사이의 값, 기본 값 1    X
//    size    Integer    한 페이지에 보여질 문서 수, 1~80 사이의 값, 기본 값 80
    func search(query: String, page: Int, size: Int = 80, sort: SearchSort = .accuracy) async throws -> KakaoResponse? {
        guard var components = URLComponents(string: Kakao.baseUrl.rawValue) else { return nil}
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "size", value: "\(String(size))"),
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url) 
        request.httpMethod = "GET"
        request.addValue("KakaoAK \(Kakao.REST_API_KEY.rawValue)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(KakaoResponse.self, from: data)
    }
}

