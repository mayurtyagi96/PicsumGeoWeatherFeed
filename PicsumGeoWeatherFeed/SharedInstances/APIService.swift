//
//  APIService.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import Foundation
import UIKit

enum APIEndpoint {
    static let picsumBaseURL = "https://picsum.photos"
    static let picsumList = "\(picsumBaseURL)/list"
    static let imageBase = "\(picsumBaseURL)/400/300?image="
    
    static func weatherURL(lat: Double, lon: Double) -> String {
        return "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,wind_speed_10m"
    }
}

enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case statusCode(Int)
    case invalidResponse
    case imageCreationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .network(let error): return "Network error: \(error.localizedDescription)"
        case .decoding(let error): return "Decoding error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from server."
        case .statusCode(let code): return "Server returned status code \(code)."
        case .imageCreationFailed: return "Failed to create image from data."
        case .unknown: return "Unknown error."
        }
    }
}

class APIService {
    static let shared = APIService()
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Generic Data Fetcher
    
    func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIServiceError.invalidURL
        }
        let request = URLRequest(url: url)
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw APIServiceError.invalidResponse
            }
            
            guard (200...299).contains(http.statusCode) else {
                throw APIServiceError.statusCode(http.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw APIServiceError.decoding(error)
            }
        } catch {
            throw APIServiceError.network(error)
        }
    }
    
    // MARK: - Public APIs
    
    func getPicsumListData() async throws -> [PicsumModel] {
        try await fetch([PicsumModel].self, from: APIEndpoint.picsumList)
    }
    
    func getWeatherData(lat: Double, lon: Double) async throws -> WeatherModel {
        let urlString = APIEndpoint.weatherURL(lat: lat, lon: lon)
        return try await fetch(WeatherModel.self, from: urlString)
    }
    
    func getImage(from url: URL) async throws -> (Data, UIImage) {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                throw APIServiceError.invalidResponse
            }
            
            guard let image = UIImage(data: data) else {
                throw APIServiceError.imageCreationFailed
            }
            return (data, image)
        } catch {
            throw APIServiceError.network(error)
        }
    }
}

