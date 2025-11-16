//
//  MapView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//
import SwiftUI
import GoogleMaps

struct PicsumMapView: View {
    let items: [MapImageMarker]   // <-- your parsed markers come here
    
    var body: some View {
        ZStack{
            GoogleMapViewRepresentable(
                items: items
            )
            .edgesIgnoringSafeArea(.all)
//            .task {
//                await viewModel.getListData()
//                withAnimation { isLoading = false }
//                print(viewModel.listData.count)
//            }
        
        }
    }
}


struct GoogleMapViewRepresentable: UIViewRepresentable {
    let items: [MapImageMarker]   // <-- your parsed markers come here

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        
                if let first = items.first {
                    let camera = GMSCameraPosition(
                        latitude: first.lat,
                        longitude: first.lon,
                        zoom: 10
                    )
                    mapView.animate(to: camera)
                }

        
        addMarkers(to: mapView)
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        
        // Keep map zoom & center on first item
                if let first = items.first {
                    let camera = GMSCameraPosition(
                        latitude: first.lat,
                        longitude: first.lon,
                        zoom: 10
                    )
                    uiView.animate(to: camera)
                }

        
        addMarkers(to: uiView)
    }
    
    private func addMarkers(to map: GMSMapView) {
        for item in items {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
            marker.userData = item
            marker.map = map
            
            // Load icon asynchronously
            Task {
                if let url = URL(string: item.thumbnailURL),
                   let image = await loadImage(url: url) {

                    let resized = image.resized(to: CGSize(width: 40, height: 40))
                    let circular = resized.circularImage()

                    await MainActor.run {
                        marker.icon = circular
                    }
                }
            }

        }
    }

    private func loadImage(url: URL) async -> UIImage? {
        // 1. Cache first
        if let cached = ImageCacheManager.shared.image(for: url) {
            return cached
        }
        
        // 2. Download
        if let (data, image) = try? await APIService.shared.getImage(from: url) {
            ImageCacheManager.shared.save(data, for: url)
            return image
        }
        return nil
    }
}



struct MapImageMarker: Identifiable {
    let id: Int
    let thumbnailURL: String
    let lat: Double
    let lon: Double
}


extension MapImageMarker {
    static func fromPicsum(id: Int) -> MapImageMarker {
        // convert id to stable lat/lon
        let lat = Double((id * 7 % 140) - 70)   // -70 to +70
        let lon = Double((id * 13 % 360) - 180) // -180 to +180
        
        return MapImageMarker(
            id: id,
            thumbnailURL: "https://picsum.photos/100/100?image=\(id)",
            lat: lat,
            lon: lon
        )
    }
}

extension UIImage {

    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func circularImage() -> UIImage {
        let minEdge = min(size.width, size.height)
        let square = CGSize(width: minEdge, height: minEdge)
        
        let renderer = UIGraphicsImageRenderer(size: square)
        return renderer.image { _ in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: square))
            path.addClip()
            self.draw(in: CGRect(origin: .zero, size: square))
        }
    }
}
