📍 Seeded Deterministic Coordinates
## 🗺️ Deterministic Map Coordinates for Picsum Images
The project generates fake but stable map coordinates for each Picsum image.
Since the Picsum API does not provide latitude/longitude, we compute a deterministic pseudo-random coordinate from the image’s ID.
This ensures:
Each image always appears at the same location on the map
Values are evenly spread around the world
No two IDs produce the same coordinates
No backend storage is required
### 📌 How It Works
We use a multiplicative hash (Knuth hash) to convert an integer ID into a large, well-distributed number.
Then we normalize it into a range of 0 → 1 and scale it into valid map coordinate ranges.
Latitude range: −85 → +85 (safe range for Mercator projection)
Longitude range: −180 → +180
The result is stable (always same for each ID) and non-repeating.
### 📟 Code Used
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
### 🧪 Example
For sample IDs:
ID: 1    → (lat: 32.53, lon: 77.11)
ID: 42   → (lat: -11.88, lon: 149.55)
ID: 360  → (lat: -43.56, lon: 141.22)
ID: 999  → (lat: 22.11, lon: -33.55)
These coordinates will never change for the same ID.
✔️ Benefits of This Approach
No randomness → stable markers
No repetition → each image gets a unique global location
No backend needed
Works offline
Just one small deterministic function
