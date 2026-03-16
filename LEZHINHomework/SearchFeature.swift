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
//    @Dependency(\.searchClient) var searchClient
    let searchClient = DependencyValues.searchClient
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var searchInput: String = ""
        public var searchedInput: String = ""
        public var isLoading: Bool = false
        public var searchResult: KakaoResponse?
        public var errorMsg: String = ""
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case searchTextChanged(String)
        case searchResponse(KakaoResponse)
        case cancelSearch
    }
    private let searchCancelID = "searchCancelID"
    
    public var body: some Reducer<State, Action> { 
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .cancelSearch:
                return .cancel(id: searchCancelID)
                
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
                    } catch {
                        
                    }
                }
                .cancellable(id: searchCancelID, cancelInFlight: true)

            case .searchTextChanged(let input):
                print("\(input)")
                state.isLoading = true
                state.searchedInput = input
                return .run { send in
                    if let response = try await searchClient.search(input) {
                        await send(.searchResponse(response))
                    }
                }
                
            case .searchResponse(let response):
                state.searchResult = response
                state.isLoading = false
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
