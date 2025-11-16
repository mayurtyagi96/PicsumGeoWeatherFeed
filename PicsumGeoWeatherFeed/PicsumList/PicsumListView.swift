//
//  ContentView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData

struct PicsumListView: View {
    @StateObject private var viewModel = PicsumListViewModel()

    var body: some View {
        List(viewModel.listData) { item in
            VStack(alignment: .leading) {
                Text(item.author)

                if let url = URL(string: "https://picsum.photos/200/300?image=\(item.id)") {
                    CachedAsyncImage(url: url)
                        .frame(height: 200)
                }
                
            }
        }
        .task {
            await viewModel.getListData()
        }
    }
}

struct CachedAsyncImage: View {
    let url: URL
    
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        // 1. Try cache
        if let cached = ImageCacheManager.shared.image(for: url) {
            self.uiImage = cached
            return
        }
        
        // 2. Download if not cached
        
        if let (data, image) = try? await APIService.shared.getImage(from: url){
            ImageCacheManager.shared.save(data, for: url)
                self.uiImage = image
        }
      
    }
}
