//
//  BookmarkUsecase.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Foundation

public struct BookmarkUsecase {
    let repo: BookmarkRepository
    public func addBookmark(doc: KakaoDocumentModel) async throws -> Void {
        _ = try await repo.addBookmark(doc: doc)
    }
    public func removeBookmark(doc: KakaoDocumentModel) async throws -> Void {
        _ = try await repo.removeBookmark(doc: doc)
    }
}
