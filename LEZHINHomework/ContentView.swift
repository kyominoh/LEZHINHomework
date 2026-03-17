//
//  ContentView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    @Bindable var store: StoreOf<ContentFeature>
    var body: some View {
        TabView {
            SearchView(store: store.scope(state: \.search, action: \.search))
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(ContentTab.search)
            BookmarkView(store: store.scope(state: \.bookmark, action: \.bookmark))
                .tabItem { Label("북마크", systemImage: "bookmark") }
                .tag(ContentTab.bookmark)
        }
        .edgesIgnoringSafeArea(.horizontal)
    }
}

#Preview {
    ContentView(store: Store(initialState: ContentFeature.State(), reducer: { ContentFeature() }))
}

