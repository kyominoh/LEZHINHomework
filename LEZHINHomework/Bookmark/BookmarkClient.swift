//
//  BookmarkClient.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Dependencies
import Foundation

public struct BookmarkClient: Sendable {
    public var toggleBookmark: @Sendable (Bool, KakaoDocumentModel) async throws -> Void
    public var bookmarkStream: @Sendable () -> AsyncStream<[BookmarkItem]>
}

extension BookmarkClient: DependencyKey {
    public static var liveValue: BookmarkClient {
        let repository = BookmarkRepository()
        let usecase = BookmarkUsecase(repo: repository)
        return Self(
            toggleBookmark: { isBookmark, doc in
                if isBookmark {
                    try await usecase.removeBookmark(doc: doc)
                } else {
                    try await usecase.addBookmark(doc: doc)
                }
            },
            bookmarkStream: {
                AsyncStream { continuation in
                    let task = Task {
                        await continuation.yield(repository.getBookmarkList())
                        for await _ in NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification) {
                            await continuation.yield(repository.getBookmarkList())
                        }
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
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

