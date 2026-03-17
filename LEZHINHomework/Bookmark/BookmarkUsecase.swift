//
//  BookmarkUsecase.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Foundation

public struct BookmarkUsecase {
    let repo: BookmarkRepository
    public func addBookmark(keyword: String, uniqueId: String) async throws -> Bool {
        try await repo.addBookmark(keyword: keyword, uniqueId: uniqueId)
    }
    public func removeBookmark(keyword: String, uniqueId: String) async throws -> Bool {
        try await repo.removeBookmark(keyword: uniqueId, uniqueId: uniqueId)
    }
}
