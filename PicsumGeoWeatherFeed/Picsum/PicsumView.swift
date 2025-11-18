//
//  ContentView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData

struct PicsumView: View {
    @StateObject private var viewModel = PicsumViewModel()
    @State private var showMapView: Bool = false
    @State private var isLoading: Bool = true

    // Two flexible columns (responsive)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ZStack{
                Group{
                    if !showMapView{
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.listData) { item in
                                    PicsumGridItemView(item: item)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                    }else{
                        PicsumMapView(items: viewModel.listData.map { MapImageMarker.fromPicsum(id: $0.id) })
                    }
                }
                
//             Loader overlay on top of map
                if isLoading {
                    VStack {
                        ProgressView("Loading data...")
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .toolbar{
                Toggle("", isOn: $showMapView)
                    .toggleStyle(ListMapToggleStyle())
                    .labelsHidden()
            }
//            .navigationTitle("Picsum Grid")
        }
        .task {
            await viewModel.getListData()
            isLoading = false
        }
    }
}

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
                .task {
                    self.uiImage = await ImageLoader.loadImage(url: url)
                }
            }
        }
    }
}
