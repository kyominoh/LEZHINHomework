//
//  CacheImageView.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct CacheImageView: View {
    var doc: KakaoDocumentModel
    var isBookmarked: Bool
    var toggleBookmark: () -> Void
    
    @State private var image: UIImage?
    @State private var retryCount = 0
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                HStack {
                    Spacer()
                    VStack {
                        Button(action: toggleBookmark) {
                            Image(systemName: isBookmarked ? "heart.fill" : "heart")
                                .foregroundColor(isBookmarked ? .red : .white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        Spacer()
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
        }
        .task(id: "\(doc.image_url):\(retryCount)") { 
            await loadImage()
        }
    }
    
    private func loadImage() async {
        if let img = MemoryCacheManager.get(forKey: doc.image_url) {
            self.image = img
            return
        }

        let url = doc.image_url
        let result = await Task.detached(priority: .userInitiated) { () -> UIImage? in
            if let img = await DiskCacheManager.shared.load(url) {
                return img
            }
            guard let imageURL = URL(string: url),
                  let (data, _) = try? await URLSession.shared.data(from: imageURL) else {
                return nil
            }
            return UIImage(data: data)
        }.value

        if let result {
            MemoryCacheManager.set(result, forKey: url)
            self.image = result
            Task.detached(priority: .background) {
                await DiskCacheManager.shared.save(result, key: url)
            }
        } else if retryCount < 1 {
            retryCount += 1
        }
    }
}
