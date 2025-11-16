//
//  APIService.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    let session: URLSession = {
        URLSession(configuration: .default)
    }()
    
    func getPicsumListData() async throws -> [PicsumModel]{
        guard let url = URL(string: "https://picsum.photos/list") else { return [] }
        let request = URLRequest(url: url)
        
        do{
            let (data, _) = try await session.data(for: request)
//            let dataAsString = String(data: data, encoding: .utf8)
//            print(dataAsString ?? "")
            let parsedData: [PicsumModel] = try JSONDecoder().decode([PicsumModel].self, from: data)
            return parsedData
        }catch{
            print(error)
        }
       
        return []
    }
    
    
    func getImage(from url: URL) async throws -> (Data, UIImage) {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloaded = UIImage(data: data) {
                return (data, downloaded)
            }
        } catch {
            print("Image download failed:", error)
        }
        return (Data(), UIImage())
    }
}
