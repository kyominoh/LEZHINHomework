//
//  ContentView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            SearchView(store: Store(initialState: SearchFeature.State(), reducer: { SearchFeature() }))
        }
        .edgesIgnoringSafeArea(.horizontal)
    }
}

#Preview {
    ContentView()
}
