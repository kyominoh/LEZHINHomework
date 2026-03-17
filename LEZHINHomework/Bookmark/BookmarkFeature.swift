//
//  BookmarkFeature.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct BookmarkFeature {
    @Dependency(BookmarkClient.self) var bookmarkClient
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case addBookmark(String)
        case removeBookmakr(String)
    }
    
    public var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addBookmark(let uniqueId):
                return .none
                
            case .removeBookmakr(let uniqueId):
                return .none
                
            case .binding:
                return .none
                
            default:
                return .none
            }
        }
    }
}
