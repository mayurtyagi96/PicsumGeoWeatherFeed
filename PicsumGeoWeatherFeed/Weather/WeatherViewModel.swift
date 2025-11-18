//
//  WeatherViewModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//
import SwiftUI
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var weather: WeatherModel?

    func fetchWeather(lat: Double, lon: Double) async{
        self.weather = try? await APIService.shared.getWeatherData(lat: lat, lon: lon)
    }
}
