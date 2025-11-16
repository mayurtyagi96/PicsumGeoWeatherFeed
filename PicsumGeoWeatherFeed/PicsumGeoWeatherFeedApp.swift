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
            PicsumGridView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
//AIzaSyAaBV5632QYHczQMBi3VK3dKXE8KUWkfAA
