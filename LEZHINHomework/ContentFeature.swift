//
//  ContentFeature.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/17/26.
//

import ComposableArchitecture
import Foundation

public enum ContentTab: Hashable, Sendable {
    case search
    case bookmark
}


@Reducer
public struct ContentFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        var tab: ContentTab = .search
        var search = SearchFeature.State()
        var bookmark = BookmarkFeature.State()
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case tabChanged(ContentTab)
        case search(SearchFeature.Action)
        case bookmark(BookmarkFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.search, action: \.search) {  SearchFeature() }
        Scope(state: \.bookmark, action: \.bookmark) { BookmarkFeature() }
        
        Reduce { state, action in
            switch action {
            case .tabChanged(let tab):
                return .none
                
            case .binding:
                return .none
            
            default:
                return .none
            }
        }
    }
}
