//
//  WeatherModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//

import Foundation

struct WeatherModel: Codable {
    let latitude: Double
    let longitude: Double
    let generationtimeMS: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let currentUnits: CurrentUnits
    let current: CurrentWeather

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
    }
}

struct CurrentUnits: Codable {
    let time: String
    let interval: String
    let temperature2M: String
    let relativeHumidity2M: String
    let windSpeed10M: String

    enum CodingKeys: String, CodingKey {
        case time
        case interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case windSpeed10M = "wind_speed_10m"
    }
}

struct CurrentWeather: Codable {
    let time: String
    let interval: Int
    let temperature2M: Double
    let relativeHumidity2M: Int
    let windSpeed10M: Double

    enum CodingKeys: String, CodingKey {
        case time
        case interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case windSpeed10M = "wind_speed_10m"
    }
}
