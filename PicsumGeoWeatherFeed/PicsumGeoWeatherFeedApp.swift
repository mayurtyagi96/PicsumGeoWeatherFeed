//
//  PicsumGeoWeatherFeedApp.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData
import GoogleMaps

@main
struct PicsumGeoWeatherFeedApp: App {
    let persistenceController = PersistenceController.shared

    // Read Google Maps API key from Info.plist
    private var googleMapsAPIKey: String? {
        Bundle.main.infoDictionary?["GoogleMapsAPIKey"] as? String
    }

    init() {
        // Initialize Google Maps SDK with API key if available
        if let apiKey = googleMapsAPIKey, !apiKey.isEmpty {
             GMSServices.provideAPIKey(apiKey)
            print("Google Maps API key loaded from Info.plist")
        } else {
            print("Warning: Google Maps API key not found in Info.plist")
        }
    }

    var body: some Scene {
        WindowGroup {
            PicsumView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
