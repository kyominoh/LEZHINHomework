//
//  BookmarkClient.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Dependencies

public struct BookmarkClient {
    public var addBookmark: @Sendable (String, String) async throws -> Bool
    public var removeBookmark: @Sendable (String, String) async throws -> Bool
}

extension BookmarkClient: DependencyKey {
    public static var liveValue: BookmarkClient {
        let repository = BookmarkRepository()
        let usecase = BookmarkUsecase(repo: repository)
        return Self(
            addBookmark: { keyword, uniqueId in
                try await usecase.addBookmark(keyword: keyword, uniqueId: uniqueId)
            }, 
            removeBookmark: { keyword, uniqueId in
                try await usecase.removeBookmark(keyword: keyword, uniqueId: uniqueId)
            }
        )
    }
}

extension DependencyValues {
    public var bookmarkClient: BookmarkClient {
        get { self[BookmarkClient.self] }
        set { self[BookmarkClient.self] = newValue }
    }
}
