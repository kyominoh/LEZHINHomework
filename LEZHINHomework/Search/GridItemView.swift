//
//  GridItemView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/22/26.
//

import SwiftUI

struct GridItemView: View {
    let items: [KakaoDocumentModel]
    let columns: Int = 3
    let spacing: CGFloat = 5
    let isBookmarked: (KakaoDocumentModel) -> Bool
    let onBookmark: (KakaoDocumentModel) -> Void
    let onLastItem: () -> Void
    let isLoading: Bool
    let isEnd: Bool

    var body: some View {
        GeometryReader { geometry in
            let columnWidth = columnWidth(totalWidth: geometry.size.width)
            let distributed = distributeItems(columnWidth: columnWidth)

            ScrollView {
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(0..<distributed.count, id: \.self) { colIndex in
                        LazyVStack(spacing: spacing) {
                            ForEach(distributed[colIndex]) { doc in
                                CacheImageView(doc: doc, isBookmarked: isBookmarked(doc), toggleBookmark: { onBookmark(doc) }
                                )
                                .frame(width: columnWidth)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onAppear {
                                    if doc.id == items.last?.id {
                                        onLastItem()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(spacing)

                if isLoading {
                    ProgressView().padding()
                }

                if isEnd {
                    Text("총 \(items.count)개")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
    }
    
    private func columnWidth(totalWidth: CGFloat) -> CGFloat {
        let totalSpacing = spacing * CGFloat(columns + 1)
        return (totalWidth - totalSpacing) / CGFloat(columns)
    }

    private func distributeItems(columnWidth: CGFloat) -> [[KakaoDocumentModel]] {
        var cols = Array(repeating: [KakaoDocumentModel](), count: columns)
        var heights = Array(repeating: CGFloat.zero, count: columns)
        for item in items {
            let shortestCol = heights.indices.min { heights[$0] < heights[$1] } ?? 0
            cols[shortestCol].append(item)
            let aspectRatio: CGFloat = item.width > 0 ? CGFloat(item.height) / CGFloat(item.width) : 1.0
            heights[shortestCol] += aspectRatio * columnWidth + spacing
        }
        return cols
    }
}
