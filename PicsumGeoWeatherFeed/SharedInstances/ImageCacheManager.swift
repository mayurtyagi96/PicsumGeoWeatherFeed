//
//  Untitled.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import Foundation
import UIKit
import SwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() {}
    
    private let cache = URLCache.shared
    
    func image(for url: URL) -> UIImage? {
        if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }
    
    func save(_ data: Data, for url: URL) {
        let response = URLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: URLRequest(url: url))
    }
}
