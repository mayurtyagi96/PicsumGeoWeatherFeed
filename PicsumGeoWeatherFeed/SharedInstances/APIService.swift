//
//  APIService.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

import Foundation
import UIKit

enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case imageCreationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .network(let error): return "Network error: \(error.localizedDescription)"
        case .decoding(let error): return "Decoding error: \(error.localizedDescription)"
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
            let (data, _) = try await session.data(for: request)
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
        try await fetch([PicsumModel].self, from: "https://picsum.photos/list")
    }

    func getWeatherData(lat: Double, lon: Double) async throws -> WeatherModel {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,wind_speed_10m"
        return try await fetch(WeatherModel.self, from: urlString)
    }

    func getImage(from url: URL) async throws -> (Data, UIImage) {
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw APIServiceError.imageCreationFailed
            }
            return (data, image)
        } catch {
            throw APIServiceError.network(error)
        }
    }
}
