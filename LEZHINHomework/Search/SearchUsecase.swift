//
//  SearchUsecase.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

public struct SearchUsecase: Sendable {
    let searchRep: SearchProtocol
    let bookmarkRepo: BookmarkProtocol
    
    public func search(input: String, page: Int) async throws -> KakaoResponse? {
        try await searchRep.search(query: input, page: page, size: 20, sort: .accuracy)
    }
}
