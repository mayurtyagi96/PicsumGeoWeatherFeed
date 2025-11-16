//
//  ContentView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData

struct PicsumGridView: View {
    @StateObject private var viewModel = PicsumViewModel()

    // Two flexible columns (responsive)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.listData) { item in
                        PicsumGridItemView(item: item)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Picsum Grid")
        }
        .task {
            await viewModel.getListData()
        }
    }
}


//struct PicsumRowView: View {
//    let item: PicsumModel
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            
//            // IMAGE
//            if let url = URL(string: "https://picsum.photos/500/300?image=\(item.id)") {
//                CachedAsyncImage(url: url)
//                    .frame(height: 200)
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//            }
//            
//            // TEXT INFO
//            VStack(alignment: .leading, spacing: 6) {
//                Text(item.author)
//                    .font(.headline)
//                
//                HStack {
//                    Label("\(item.width)x\(item.height)", systemImage: "photo")
//                        .font(.caption)
//                    Spacer()
//                    Text(item.format.uppercased())
//                        .font(.caption)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 2)
//                        .background(Color.blue.opacity(0.15))
//                        .cornerRadius(6)
//                }
//                
//                Text("File: \(item.filename)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                // LINK TO POST
////                if let url = URL(string: item.post_url) {
////                    Link("View Source", destination: url)
////                        .font(.caption)
////                        .foregroundColor(.blue)
////                }
//            }
//            .padding(.horizontal, 4)
//
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 6)
//        )
//    }
//}
struct PicsumGridItemView: View {
    let item: PicsumModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Image
            if let url = URL(string: "https://picsum.photos/400/300?image=\(item.id)") {
                CachedAsyncImage(url: url)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Author
            Text(item.author)
                .font(.subheadline)
                .fontWeight(.medium)

            // Sizes
            Text("\(item.width)x\(item.height)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
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
                    .scaledToFill()
                    .clipped()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.15))
                    ProgressView()
                }
                .task { await loadImage() }
            }
        }
    }
    
    private func loadImage() async {
        // 1. Cache first
        if let cached = ImageCacheManager.shared.image(for: url) {
            self.uiImage = cached
            return
        }
        
        // 2. Download
        if let (data, image) = try? await APIService.shared.getImage(from: url) {
            ImageCacheManager.shared.save(data, for: url)
            self.uiImage = image
        }
    }
}
