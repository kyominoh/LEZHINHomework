//
//  SearchClient.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Dependencies

public struct SearchClient: Sendable {
    public var search: @Sendable (String) async throws -> KakaoResponse?
}

extension SearchClient: DependencyKey {
    public static var liveValue: SearchClient {
        let searchRepo = SearchRepository()
        let bookmarkRepo = BookmarkRepository()
        let usecase = SearchUsecase(searchRep: searchRepo, bookmarkRepo: bookmarkRepo)
        return Self (
            search: { input in
                try await usecase.search(input: input)
            }
        )
    }
}

extension DependencyValues {
    public var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}
