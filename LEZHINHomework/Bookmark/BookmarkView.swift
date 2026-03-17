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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BookmarkView(store: Store(initialState: BookmarkFeature.State(), reducer: { BookmarkFeature()
    }))
}

