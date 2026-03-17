//
//  KakaoResponse.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

public struct KakaoResponse: Codable, Sendable, Equatable {
    public static func == (lhs: KakaoResponse, rhs: KakaoResponse) -> Bool {
        lhs.documents == rhs.documents
    }
    
    let meta: KakaoMetaModel
    let documents: [KakaoDocumentModel]
}

public struct KakaoMetaModel: Codable, Sendable, Equatable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}

public struct KakaoDocumentModel: Codable, Sendable, Identifiable, Equatable {
    public var id: String { image_url }
    let collection: String
    let thumbnail_url: String
    let image_url: String
    let width: Int
    let height: Int
    let display_sitename: String
    let doc_url: String
    let datetime: String
}
