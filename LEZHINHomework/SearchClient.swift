//
//  SearchClient.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Dependencies

public struct SearchClient {
    public var search: @Sendable (String) async throws -> AsyncStream<[ResultModel]> 
}

extension SearchClient: DependencyKey {
    public static var liveValue: SearchClient {
        let repository = SearchRepository()
        let usecase = SearchUsecase(repository: repository)
        return Self (
            search: { input in
                try await usecase.search(input: input)
            }
        )
    }
}

extension DependencyValues {
    var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}
