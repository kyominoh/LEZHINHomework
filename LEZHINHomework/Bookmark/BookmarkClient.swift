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
                    Task.detached {
                        let bookmarkList = await repository.getBookmarkList()
                        continuation.yield(bookmarkList)
                    }
                    
                    let observor = NotificationCenter.default.addObserver(
                        forName: UserDefaults.didChangeNotification,
                        object: nil,
                        queue: .current
                    ) { _ in
                        Task.detached {
                            let updatedList = await repository.getBookmarkList()
                            continuation.yield(updatedList)
                        }
                    }
                    let holder = AsyncStreamReleasable(observor)
                    continuation.onTermination = { @Sendable _ in
                        Task {
                            await holder.clearObject()
                        }
                    }
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

actor AsyncStreamReleasable {
    var target: AnyObject?
    init(_ target: AnyObject) {
        self.target = target
    }
    func clearObject() {
        if let target = self.target as? NSObjectProtocol {
            NotificationCenter.default.removeObserver(target)
        } 
    }
}
