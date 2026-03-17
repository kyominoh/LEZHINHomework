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
                if let documents = store.searchResult?.documents as? [KakaoDocumentModel] {
                    listView(documents: documents)
                } else if !store.errorMsg.isEmpty {
                    Text(store.errorMsg)
                        .foregroundStyle(.red)
                } else {
                    
                }
            }
        }
    }
    
    @ViewBuilder
    func listView(documents: [KakaoDocumentModel]) -> some View {
        if documents.isEmpty {
            Text("검색 결과가 없습니다.")
        }
        LazyVStack(spacing: 0) { 
            ForEach(documents) { doc in
                AsyncImage(url: URL(string: doc.image_url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)    
                            .background(Color.black.opacity(0.05))
                        
                    case .failure:
                        Image(systemName: "photo")
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.gray.opacity(0.1))
                        
                    case .empty:
                        ProgressView()
                                   .frame(maxWidth: .infinity)
                                   .frame(height: 200)
                        
                    @unknown default:
                        EmptyView()
                    }
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
