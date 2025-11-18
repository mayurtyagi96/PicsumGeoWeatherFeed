//
//  WeatherView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//
import SwiftUI
import CoreLocation

struct WeatherView: View {
    
    @StateObject var viewModel = WeatherViewModel()
    let coordinates: CLLocationCoordinate2D
    let imageID: Int?

    var body: some View {
        VStack {
            if let url = URL(string: "https://picsum.photos/400/300?image=\(imageID ?? 0)") {
                CachedAsyncImage(url: url)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Text(viewModel.weather?.timezone ?? "loading..." )
        }
        .task {
            await viewModel.fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
        }
        .padding()
    }
}
