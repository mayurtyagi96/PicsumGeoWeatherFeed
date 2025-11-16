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

struct ListMapToggleStyle: ToggleStyle {
    var listSelectedImage: String = "listSelectedSwitch"
    var mapSelectedImage: String = "mapSelectedSwitch"
    @SwiftUI.State private var isAnimating = false
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            guard !isAnimating else { return }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                configuration.isOn.toggle()
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAnimating = false
                }
            }
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(configuration.isOn ? mapSelectedImage : listSelectedImage)
            }
        }
        .buttonStyle(.plain)
        .disabled(isAnimating)
        .opacity(isAnimating ? 0.3 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}
