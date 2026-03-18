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
        var bookmarkList: [BookmarkItem] = []
        public var errorMsg: String = ""
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case bookmarkStream
        case updateBookmarkList([BookmarkItem])
        case toggleBookmark(KakaoDocumentModel)
        case error(String)
    }
    
    public var body : some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .bookmarkStream:
                return .run { send in
                    for await bookmarkList in await bookmarkClient.bookmarkStream() {
                        await send(.updateBookmarkList(bookmarkList))
                    }
                }
                
            case .updateBookmarkList(let bookmarkList):
                state.bookmarkList = bookmarkList
                return .none
                
            case .toggleBookmark(let doc):
                let isBookmarked = state.isBookmarked(document: doc)
                return .run { send in
                    do {
                        try await bookmarkClient.toggleBookmark(isBookmarked, doc)
                    } catch { 
                        await send(.error(error.localizedDescription))
                    }
                }
                
            case .error(let errorMessage):
                state.errorMsg = errorMessage
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

extension BookmarkFeature.State {
    func isBookmarked(document: KakaoDocumentModel) -> Bool {
        return bookmarkList.contains(where: { $0.data == document })
    }
}
