//
//  BookmarkRepository.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import Foundation

public protocol BookmarkProtocol {
    func addBookmark(keyword: String, uniqueId: String) async throws -> Bool
    func removeBookmark(keyword: String, uniqueId: String) async throws -> Bool
}

public struct BookmarkRepository: BookmarkProtocol {
    public func addBookmark(keyword: String, uniqueId: String) async throws -> Bool {
        return false
    }
    
    public func removeBookmark(keyword: String, uniqueId: String) async throws -> Bool {
        return false
    }
}
