import XCTest
@testable import PicsumGeoWeatherFeed
import Foundation
import CoreLocation
import Combine

// MARK: - 1. WeatherModel Decoding

final class WeatherModelDecodingTests: XCTestCase {
    func testWeatherModelDecoding() throws {
        let json = """
        {
            "latitude": 40.0,
            "longitude": -75.0,
            "generationtime_ms": 2.8,
            "utc_offset_seconds": 0,
            "timezone": "America/New_York",
            "timezone_abbreviation": "EDT",
            "elevation": 100.0,
            "current_units": {
                "time": "iso8601",
                "interval": "seconds",
                "temperature_2m": "°C",
                "relative_humidity_2m": "%",
                "wind_speed_10m": "m/s"
            },
            "current": {
                "time": "2025-11-18T08:00:00Z",
                "interval": 0,
                "temperature_2m": 17.1,
                "relative_humidity_2m": 44,
                "wind_speed_10m": 2.5
            }
        }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(WeatherModel.self, from: json)
        XCTAssertEqual(decoded.latitude, 40.0)
        XCTAssertEqual(decoded.longitude, -75.0)
        XCTAssertEqual(decoded.current.temperature2M, 17.1)
        XCTAssertEqual(decoded.current.relativeHumidity2M, 44)
        XCTAssertEqual(decoded.timezone, "America/New_York")
    }
}

// MARK: - 2. Pagination Logic (Assuming PicsumViewModel)

final class PaginationTests: XCTestCase {
    struct MockPicsumModel: Identifiable {
        let id: Int
    }

    class MockPicsumViewModel {
        var allItems: [MockPicsumModel]
        var pageSize = 10
        var currentPage = 0

        init(items: [MockPicsumModel]) {
            self.allItems = items
        }

        func pagedItems() -> [MockPicsumModel] {
            let start = currentPage * pageSize
            return Array(allItems.dropFirst(start).prefix(pageSize))
        }

        func nextPage() {
            currentPage += 1
        }

        var hasMorePages: Bool {
            (currentPage + 1) * pageSize < allItems.count
        }
    }

    func testPagination() {
        let models = (0..<25).map { MockPicsumModel(id: $0) }
        let vm = MockPicsumViewModel(items: models)

        let page1 = vm.pagedItems()
        XCTAssertEqual(page1.count, 10)
        XCTAssertEqual(page1.first?.id, 0)
        XCTAssertEqual(page1.last?.id, 9)

        vm.nextPage()
        let page2 = vm.pagedItems()
        XCTAssertEqual(page2.count, 10)
        XCTAssertEqual(page2.first?.id, 10)
        XCTAssertEqual(page2.last?.id, 19)

        vm.nextPage()
        let page3 = vm.pagedItems()
        XCTAssertEqual(page3.count, 5)
        XCTAssertEqual(page3.first?.id, 20)
        XCTAssertEqual(page3.last?.id, 24)

        XCTAssertFalse(vm.hasMorePages)
    }
}

// MARK: - 3. Weather Fetch Logic (Mocked API)

final class WeatherFetchTests: XCTestCase {
    actor MockAPIService {
        var didCall: Bool = false

        func getWeatherData(lat: Double, lon: Double) async throws -> WeatherModel {
            didCall = true
            return WeatherModel(
                latitude: lat,
                longitude: lon,
                generationtimeMS: 1.1,
                utcOffsetSeconds: 0,
                timezone: "Europe/Paris",
                timezoneAbbreviation: "CET",
                elevation: 120,
                currentUnits: CurrentUnits(
                    time: "iso8601",
                    interval: "seconds",
                    temperature2M: "°C",
                    relativeHumidity2M: "%",
                    windSpeed10M: "m/s"
                ),
                current: CurrentWeather(
                    time: "2025-11-18T12:00:00Z",
                    interval: 0,
                    temperature2M: 13.0,
                    relativeHumidity2M: 50,
                    windSpeed10M: 4.0
                )
            )
        }
    }

    class TestableWeatherViewModel: ObservableObject {
        @Published var weather: WeatherModel?
        let api: MockAPIService

        init(api: MockAPIService) {
            self.api = api
        }
        func fetchWeather(lat: Double, lon: Double) async {
            self.weather = try? await api.getWeatherData(lat: lat, lon: lon)
        }
    }

    func testFetchWeather() async throws {
        let api = MockAPIService()
        let vm = TestableWeatherViewModel(api: api)
        await vm.fetchWeather(lat: 42.0, lon: 2.0)
        let weather = vm.weather

        XCTAssertEqual(weather?.latitude, 42.0)
        XCTAssertEqual(weather?.longitude, 2.0)
        XCTAssertEqual(weather?.timezone, "Europe/Paris")
        XCTAssertEqual(weather?.current.temperature2M, 13.0)
        XCTAssertEqual(weather?.current.relativeHumidity2M, 50)
    }
}

