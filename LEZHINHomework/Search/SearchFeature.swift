//
//  SearchFeature.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct SearchFeature {
    @Dependency(\.continuousClock) var clock
    @Dependency(SearchClient.self) var searchClient
    @Dependency(BookmarkClient.self) var bookmarkClient
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var searchInput: String = ""
        public var searchedInput: String = ""
        public var isLoading: Bool = false
        public var searchDocuments: [KakaoDocumentModel] = []
        public var errorMsg: String = ""
        public var bookmarkList: [BookmarkItem] = []
        public var page: Int = 1
        public var isEnd: Bool = false
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case searchTextChanged(String)
        case searchResponse(KakaoResponse)
        case error(String)
        case bookmarkStream
        case updateBookmarkList([BookmarkItem])
        case toggleBookmark(KakaoDocumentModel)
        case searchNext
    }
    private let searchCancelID = "searchCancelID"
    
    public var body: some Reducer<State, Action> { 
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchInput):
                let input = state.searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !input.isEmpty else {
                    return .cancel(id: searchCancelID)
                }
                let searchedInput = state.searchedInput
                return .run { send in
                    do {
                        try await clock.sleep(for: .seconds(1))
                        if searchedInput != input {
                            await send(.searchTextChanged(input))
                        }
                    } catch is CancellationError {
                        // Handle cancellation if needed
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }
                .cancellable(id: searchCancelID, cancelInFlight: true)

            case .searchTextChanged(let input):
                print("\(input)")
                state.searchedInput = input
                state.isEnd = false
                state.searchDocuments = [] 
                state.page = 1
                return .run { send in
                    await send(.searchNext)
                }
                
            case .searchNext:
                guard !state.isLoading, !state.isEnd, !state.searchInput.isEmpty else { return .none }

                state.isLoading = true
                let input = state.searchInput
                let page = state.page
                return .run { send in
                    if let response = try await searchClient.search(input, page) {
                        await send(.searchResponse(response))
                    }
                }
                
            case .searchResponse(let response):
                state.searchDocuments.append(contentsOf: response.documents)
                state.isLoading = false
                state.isEnd = response.meta.is_end
                if state.page < response.meta.pageable_count {
                    state.page += 1
                } 
                return .none
                
            case .error(let localizedDescription):
                state.errorMsg = localizedDescription
                return .none
                
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
                let isBookmarked = state.isBookmarked(doc: doc)
                return .run { send in
                    do {
                        try await bookmarkClient.toggleBookmark(isBookmarked, doc)
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }
                
            case .binding:
                return .none
            }
        }
    }
}

extension SearchFeature.State {
    func isBookmarked(doc: KakaoDocumentModel) -> Bool {
        bookmarkList.contains { $0.data.image_url == doc.image_url }
    }
}
