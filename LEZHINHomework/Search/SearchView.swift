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
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            resultContent
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("검색어 입력", text: $store.searchInput)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        if !store.searchInput.isEmpty {
                            Button {
                                store.searchInput = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.bar)
                }
                .onAppear { store.send(.bookmarkStream) }
                .navigationTitle("검색")
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Result Content

    @ViewBuilder
    private var resultContent: some View {
        if !store.searchDocuments.isEmpty {
            if sizeClass == .regular {
                GridItemView(
                    items: store.searchDocuments,
                    isBookmarked: { store.state.isBookmarked(doc: $0) },
                    onBookmark: { store.send(.toggleBookmark($0)) },
                    onLastItem: { store.send(.searchNext) },
                    isLoading: !store.searchInput.isEmpty && store.state.isLoading,
                    isEnd: !store.searchInput.isEmpty && store.isEnd
                )
            } else {
                phoneLayout
            }
        } else if !store.errorMsg.isEmpty {
            VStack {
                Spacer()
                Text(store.errorMsg)
                    .foregroundStyle(.red)
                    .padding()
                Spacer()
            }
        } else {
            Spacer()
        }
    }

    // MARK: - Phone Scroll Layout

    private var phoneLayout: some View {
        ScrollView {
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
                    Text("총 \(store.searchDocuments.count)개")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    SearchView(store: Store(initialState: SearchFeature.State(), reducer: {
        SearchFeature()
    }))
}
