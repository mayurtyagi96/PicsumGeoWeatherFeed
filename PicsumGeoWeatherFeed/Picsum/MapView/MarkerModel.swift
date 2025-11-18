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
        // convert id to stable lat/lon
        let lat = Double((id * 7 % 140) - 70)   // -70 to +70
        let lon = Double((id * 13 % 360) - 180) // -180 to +180
        
        return MapImageMarker(
            id: id,
            thumbnailURL: "\(APIEndpoint.thumbnailBase)\(id)",  // Use the constant here
            lat: lat,
            lon: lon
        )
    }
}
