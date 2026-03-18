//
//  SearchView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    var body: some View {
        VStack {
            TextField("검색어 입력", text: $store.searchInput)
                .padding()
            ScrollView {
                if !store.searchDocuments.isEmpty {
                    LazyVStack(spacing: 0) { 
                        ForEach(store.searchDocuments) { doc in
                            CacheImageView(doc: doc, isBookmarked: store.state.isBookmarked(doc: doc)) { 
                                store.send(.toggleBookmark(doc))
                            }
                            .onAppear {
                                if doc == store.searchDocuments.last {
                                    store.send(.searchNext)
                                }
                            }
                        }
                        if !store.searchInput.isEmpty && store.state.isLoading {
                            ProgressView().padding()
                        }
                        if !store.searchInput.isEmpty && store.isEnd {
                            Text("총 \(store.searchDocuments.count)개").padding()
                        }
                    }
                } else if !store.errorMsg.isEmpty {
                    Text(store.errorMsg)
                        .foregroundStyle(.red)
                } else {
                    
                }
            }
        }
        .onAppear { 
            store.send(.bookmarkStream)
        }
    }
}


#Preview {
    SearchView(store: Store(initialState: SearchFeature.State(), reducer: { 
        SearchFeature()
    }))
}
