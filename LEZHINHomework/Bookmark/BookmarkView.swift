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
        ZStack {
            if store.state.errorMsg.count > 0 {
                Text(store.state.errorMsg)
            }
            VStack {
                ScrollView {
                    let documents: [KakaoDocumentModel] = store.bookmarkList.map(\.data)
                    if documents.count > 0 {
                        LazyVStack(spacing: 0) { 
                            ForEach(documents) { doc in
                                CacheImageView(doc: doc, isBookmarked: store.state.isBookmarked(document: doc)) { 
                                    store.send(.toggleBookmark(doc))
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.bookmarkStream)
        }
    }
}

#Preview {
    BookmarkView(store: Store(initialState: BookmarkFeature.State(), reducer: { BookmarkFeature()
    }))
}

