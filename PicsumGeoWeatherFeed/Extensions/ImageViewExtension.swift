//
//  ImageViewExtension.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//
import UIKit

extension UIImage {

    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func circularImage() -> UIImage {
        let minEdge = min(size.width, size.height)
        let square = CGSize(width: minEdge, height: minEdge)
        
        let renderer = UIGraphicsImageRenderer(size: square)
        return renderer.image { _ in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: square))
            path.addClip()
            self.draw(in: CGRect(origin: .zero, size: square))
        }
    }
}
