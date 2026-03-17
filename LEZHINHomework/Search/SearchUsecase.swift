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
    
    public func search(input: String) async throws -> KakaoResponse? {
        let response = try await searchRep.search(query: input, page: 1, size: 80, sort: .accuracy)
        // MARK: update bookmark if needed (using bookmark Repository)
        return response
    }
}
