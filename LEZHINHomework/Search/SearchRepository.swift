//
//  SearchRepository.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

public enum SearchSort: String {
    case accuracy
    case recency
}

protocol SearchProtocol {
    func search(query: String, page: Int, size: Int, sort: SearchSort) async throws -> KakaoResponse?
}

public struct SearchRepository: Sendable, SearchProtocol {
//    query    String    검색을 원하는 질의어    O
//    sort    String    결과 문서 정렬 방식, accuracy(정확도순) 또는 recency(최신순), 기본 값 accuracy    X
//    page    Integer    결과 페이지 번호, 1~50 사이의 값, 기본 값 1    X
//    size    Integer    한 페이지에 보여질 문서 수, 1~80 사이의 값, 기본 값 80
    func search(query: String, page: Int, size: Int = 20, sort: SearchSort = .accuracy) async throws -> KakaoResponse? {
        let request = KakaoApiRequest.imageSearch(query: query, page: page, size: size, sort: sort)
        return try await NetworkWorker.request(request)
    }
}

