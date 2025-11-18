//
//  MapView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import GoogleMaps

// MARK: - Main SwiftUI Map View
struct PicsumMapView: View {
    let items: [MapImageMarker]
    @State private var selectedMarker: MapImageMarker? = nil
    
    var body: some View {
        ZStack {
            GoogleMapViewRepresentable(
                items: items,
                selectedMarker: $selectedMarker
            )
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(item: $selectedMarker) { item in
            WeatherView(
                coordinates: CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon),
                imageID: item.id
            )
            .presentationDragIndicator(.visible)
        }
    }
}



// MARK: - Google Maps Representable
struct GoogleMapViewRepresentable: UIViewRepresentable {
    let items: [MapImageMarker]
    @Binding var selectedMarker: MapImageMarker?
    
    // MARK: Coordinator
    class Coordinator: NSObject, GMSMapViewDelegate {
        let parent: GoogleMapViewRepresentable
        var currentMarkers: [GMSMarker] = []   // tracks visible markers
        
        init(parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }
        
        // Tap on marker → Open Sheet
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let item = marker.userData as? MapImageMarker {
                parent.selectedMarker = item
            }
            return true
        }
        
        // Fired when user stops moving camera
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            parent.updateVisibleMarkers(on: mapView, coordinator: self)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    
    // MARK: - Create Map
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.delegate = context.coordinator
        
        // Center camera on India
        mapView.camera = GMSCameraPosition(
            latitude: 20.5937,
            longitude: 78.9629,
            zoom: 4
        )
        
        // Load markers for initial visible bounds
        DispatchQueue.main.async {
            self.updateVisibleMarkers(on: mapView, coordinator: context.coordinator)
        }
        
        return mapView
    }

    
    
    
    // MARK: - Update UIView
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // When SwiftUI updates → refresh visible markers based on screen bounds
        updateVisibleMarkers(on: uiView, coordinator: context.coordinator)
    }
    
    
    
    // MARK: - Visible-Bounds Marker Logic
    func updateVisibleMarkers(on mapView: GMSMapView, coordinator: Coordinator) {
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        // Remove previous markers
        coordinator.currentMarkers.forEach { $0.map = nil }
        coordinator.currentMarkers.removeAll()
        
        // Add only markers inside the visible map bounds
        for item in items {
            let coordinate = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)
            
            if bounds.contains(coordinate) {
                let marker = GMSMarker(position: coordinate)
                marker.userData = item
                
                // Load image async
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
                
                marker.map = mapView
                coordinator.currentMarkers.append(marker)
            }
        }
    }
}
