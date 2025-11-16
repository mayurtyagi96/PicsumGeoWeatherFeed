//
//  MapView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//
import SwiftUI
import GoogleMaps

struct PicsumMapView: View {
    @StateObject private var viewModel = PicsumViewModel()
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack{
            GoogleMapViewRepresentable(
                items: viewModel.listData.map { MapImageMarker.fromPicsum(id: $0.id) }
            )
            .edgesIgnoringSafeArea(.all)
            .task {
                await viewModel.getListData()
                withAnimation { isLoading = false }
                print(viewModel.listData.count)
            }
            
            // Loader overlay on top of map
            if isLoading {
                VStack {
                    ProgressView("Loading markers...")
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
}


struct GoogleMapViewRepresentable: UIViewRepresentable {
    let items: [MapImageMarker]   // <-- your parsed markers come here

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        addMarkers(to: mapView)
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        addMarkers(to: uiView)
    }
    
    private func addMarkers(to map: GMSMapView) {
        for item in items {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
            marker.userData = item
            marker.map = map
        }
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
