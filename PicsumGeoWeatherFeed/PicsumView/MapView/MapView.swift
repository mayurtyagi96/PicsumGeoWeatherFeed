//
//  MapView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//
import SwiftUI
import GoogleMaps

struct MapView: View {
    @StateObject private var viewModel = PicsumListViewModel()
    
    var body: some View {
        GoogleMapViewRepresentable()
                   .edgesIgnoringSafeArea(.all)
    }
}

struct GoogleMapViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> GMSMapView {
        // Default camera position
        let camera = GMSCameraPosition.camera(
            withLatitude: 28.6139,
            longitude: 77.2090,
            zoom: 14
        )
        
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update logic if needed (markers, camera, etc.)
    }
}
