//
//  PicsumGeoWeatherFeedApp.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import SwiftUI
import CoreData

@main
struct PicsumGeoWeatherFeedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            PicsumListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
