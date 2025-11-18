//
//  MapView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//
import SwiftUI
import GoogleMaps

struct PicsumMapView: View {
    let items: [MapImageMarker]
    @State private var selectedMarker: MapImageMarker? = nil
    
    var body: some View {
        ZStack{
            GoogleMapViewRepresentable(
                items: items, selectedMarker: $selectedMarker
            )
            .edgesIgnoringSafeArea(.all)
            .sheet(item: $selectedMarker){ item in
                WeatherView(coordinates: CLLocationCoordinate2D(latitude: selectedMarker?.lat ?? 0, longitude: selectedMarker?.lon ?? 0), imageID: selectedMarker?.id)
            }
        }
    }
}

struct GoogleMapViewRepresentable: UIViewRepresentable {
    let items: [MapImageMarker]
    @Binding var selectedMarker: MapImageMarker?
    
    // MARK: - Coordinator
    class Coordinator: NSObject, GMSMapViewDelegate {
        let parent: GoogleMapViewRepresentable
        
        init(parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let item = marker.userData as? MapImageMarker {
                parent.selectedMarker = item
            }
            return true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
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
        
        mapView.delegate = context.coordinator
        
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
                   let image = await ImageLoader.loadImage(url: url) {
                    
                    let resized = image.resized(to: CGSize(width: 40, height: 40))
                    let circular = resized.circularImage()
                    
                    await MainActor.run {
                        marker.icon = circular
                    }
                }
            }
            
        }
    }
}
