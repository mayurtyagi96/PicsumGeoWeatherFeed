//
//  MarkerModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//

struct MapImageMarker: Identifiable {
    let id: Int
    let thumbnailURL: String
    let lat: Double
    let lon: Double
}

extension MapImageMarker {
    static func fromPicsum(id: Int) -> MapImageMarker {
        
        // Stable hash based on ID
        let hash = abs(id &* 2654435761)  // Knuth multiplicative hash
        
        // Map hash → 0 to 1 (normalize)
        let normalized = Double(hash % 10_000) / 10_000.0
        
        // Spread latitude (-85 to 85)
        let lat = -85 + normalized * 170
        
        // Shift the hash again for lon
        let normalized2 = Double(((hash >> 8) % 10_000)) / 10_000.0
        
        // Spread longitude (-180 to 180)
        let lon = -180 + normalized2 * 360
        
        return MapImageMarker(
            id: id,
            thumbnailURL: "\(APIEndpoint.thumbnailBase)\(id)",
            lat: lat,
            lon: lon
        )
    }
}
