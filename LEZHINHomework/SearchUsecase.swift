//
//  SearchUsecase.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

public struct SearchUsecase: Sendable {
    let repository: SearchProtocol
    
    public func search(input: String) async throws -> KakaoResponse? {
        try await repository.search(query: input, page: 1, size: 80, sort: .accuracy)
    }
}
