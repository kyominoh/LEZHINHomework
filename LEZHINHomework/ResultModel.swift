//
//  ResultModel.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import Foundation

public protocol ResultModel: Sendable {
    
}

public struct SearchResultModel: Codable, ResultModel {
    
}


extension SearchResultModel: Equatable {
    public static func == (lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
        false
    }
}
