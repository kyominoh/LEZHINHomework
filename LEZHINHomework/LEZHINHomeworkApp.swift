//
//  LEZHINHomeworkApp.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/16/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct LEZHINHomeworkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: ContentFeature.State(), reducer: { ContentFeature() }))
        }
    }
}
