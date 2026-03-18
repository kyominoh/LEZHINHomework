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
                        .padding(10)
                        Spacer()
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
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
        if let img = DiskCacheManager.shared.load(doc.image_url) {
            self.image = img
            return
        }
        guard let imageURL = URL(string: doc.image_url) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                MemoryCacheManager.set(downloadedImage, forKey: doc.image_url)
                self.image = downloadedImage
                Task.detached(priority: .background) {
                    await DiskCacheManager.shared.save(downloadedImage, key: doc.image_url)
                }
            } else {
                throw NSError(domain: "Invalid Url", code: -9999)
            }
        } catch {
            if retryCount < 1 {
                retryCount += 1
            }
        }
    }
}
