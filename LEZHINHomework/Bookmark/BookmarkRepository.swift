//
//  BookmarkRepository.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Foundation

public protocol BookmarkProtocol {
    func addBookmark(doc: KakaoDocumentModel) async throws -> Bool
    func removeBookmark(doc: KakaoDocumentModel) async throws -> Bool
}

public struct BookmarkRepository: BookmarkProtocol {
    private let bookmarkKey = "bookmark_list"
    public func addBookmark(doc: KakaoDocumentModel) async throws -> Bool {
        let item = BookmarkItem(data: doc, createdAt: Date())
        return addBookmark(item)
    }
    
    public func removeBookmark(doc: KakaoDocumentModel) async throws -> Bool {
        let item = BookmarkItem(data: doc, createdAt: Date())
        return removeBookmark(item)
    }
}

//  DB 조건은 제시되지 않았으므로 UserDefaults를 활용하여 간단히 구현

public struct BookmarkItem: Codable, Equatable {
    let data: KakaoDocumentModel
    let createdAt: Date 
    public static func == (lhs: BookmarkItem, rhs: BookmarkItem) -> Bool {
        lhs.data.image_url == rhs.data.image_url
    }
}

extension BookmarkRepository {
    func getBookmarkList() -> [BookmarkItem] {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey),
              let decoded = try? JSONDecoder().decode([BookmarkItem].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.createdAt > $1.createdAt }
    }
    func addBookmark(_ item: BookmarkItem) -> Bool {
        var list = getBookmarkList()
        if !list.contains(item) {
            list.append(item)
            return setBookmarkList(list)
        }
        return false
    }
    func removeBookmark(_ item: BookmarkItem) -> Bool {
        var list = getBookmarkList()
        list = list.filter { $0 != item }
        return setBookmarkList(list)
    }
    private func setBookmarkList(_ list: [BookmarkItem]) -> Bool {
        if let encoded = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(encoded, forKey: bookmarkKey)
            return true
        }
        return false
    }
}

