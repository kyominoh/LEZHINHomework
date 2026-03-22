//
//  BookmarkView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import SwiftUI

struct BookmarkView: View {
    let store: StoreOf<BookmarkFeature>

    var body: some View {
        NavigationStack {
            let documents: [KakaoDocumentModel] = store.bookmarkList.map(\.data)
            List {
                ForEach(documents) { doc in
                    CacheImageView(doc: doc, isBookmarked: store.state.isBookmarked(document: doc)) {
                        store.send(.toggleBookmark(doc))
                    }
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.send(.toggleBookmark(doc))
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if store.state.errorMsg.count > 0 {
                    Text(store.state.errorMsg)
                        .foregroundStyle(.red)
                }
            }
            .onAppear {
                store.send(.bookmarkStream)
            }
            .navigationTitle("북마크")
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    BookmarkView(store: Store(initialState: BookmarkFeature.State(), reducer: { BookmarkFeature()
    }))
}

