//
//  SearchRepository.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

protocol SearchProtocol {
    func search(query: String) async throws -> AsyncStream<[ResultModel]>
}

public struct SearchRepository: Sendable, SearchProtocol {
    func search(query: String) async throws -> AsyncStream<[ResultModel]> {
        AsyncStream { continuation in
            continuation.yield([])
        }
    }
}
