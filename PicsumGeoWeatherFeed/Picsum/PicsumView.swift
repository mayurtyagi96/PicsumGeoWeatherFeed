//
//  ContentView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

struct PicsumView: View {
    @StateObject private var viewModel = PicsumViewModel()
    @State private var showMapView: Bool = false

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
                            if viewModel.listData.isEmpty{
                                LazyVGrid(columns: columns, spacing: 16) {
                                        // Show skeleton items while loading
                                        ForEach(0..<6, id: \.self) { _ in
                                            SkeletonGridItemView()
                                        }
                                }
                                .padding(.horizontal)
                                .padding(.top, 12)
                            }else{
                                LazyVGrid(columns: columns, spacing: 16) {
                                        // Show actual data
                                        ForEach(viewModel.listData) { item in
                                            PicsumGridItemView(item: item)
                                        }
                                }
                                .padding(.horizontal)
                                .padding(.top, 12)
                            }
                        }
                    }else{
                        PicsumMapView(items: viewModel.listData.map { MapImageMarker.fromPicsum(id: $0.id) })
                    }
                }
                
                // Loader overlay on top of map (only show for map view or when refreshing existing data)
                if viewModel.isLoading && (!viewModel.listData.isEmpty || showMapView) {
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
             .navigationTitle("Picsum")
             .navigationBarTitleDisplayMode(.inline)
        }
        .alert(item: $viewModel.errorMessage) { errorWrapper in
            Alert(
                title: Text("Error"),
                message: Text(errorWrapper.message),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
        .task {
            await viewModel.getListData()
        }
    }
}

struct PicsumGridItemView: View {
    let item: PicsumModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Image
            if let url = URL(string: "\(APIEndpoint.imageBase)\(item.id)") {
                CachedAsyncImage(url: url)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Author
            Text(item.author)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            // Sizes
            Text("\(item.width)x\(item.height)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .scaledToFit()
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

// MARK: - Skeleton Loading Views
struct SkeletonGridItemView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image skeleton
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 150)
                .shimmer(isAnimating: isAnimating)
            
            // Author skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shimmer(isAnimating: isAnimating)
            
            // Size skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 12)
                .shimmer(isAnimating: isAnimating)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.6),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: phase * geometry.size.width * 1.5 - geometry.size.width * 0.5)
                    .animation(
                        isAnimating ? Animation.linear(duration: 1.5).repeatForever(autoreverses: false) : .default,
                        value: phase
                    )
                }
            )
            .onAppear {
                if isAnimating {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(isAnimating: Bool) -> some View {
        modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}
