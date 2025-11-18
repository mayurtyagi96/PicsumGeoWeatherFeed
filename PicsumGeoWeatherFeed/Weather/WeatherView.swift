//
//  WeatherView.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 17/11/25.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    let coordinates: CLLocationCoordinate2D
    let imageID: Int?

    var body: some View {
        OrientationReader { isLandscape in
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Image
                    if let url = URL(string: "\(APIEndpoint.imageBase)\(imageID ?? 0)") {
                        CachedAsyncImage(url: url)
                            .frame(
                                height: isLandscape ? 120 : 150
                            )
                            .frame(
                                maxWidth: isLandscape ? 240 : .infinity
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top, 12)
                    }

                    // MARK: - Weather Content
                    if let weather = viewModel.weather {
                        WeatherDetailCard(weather: weather, isLandscape: isLandscape)
                            .transition(.opacity)
                    } else {
                        WeatherSkeletonCard(isLandscape: isLandscape)
                            .transition(.opacity)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
        }
        .animation(.easeInOut, value: viewModel.weather)
    }
}


// MARK: - Orientation Reader Helper
struct OrientationReader<Content: View>: View {
    @ViewBuilder var content: (Bool) -> Content   // true = landscape

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            content(isLandscape)
        }
    }
}


// MARK: - Weather Data Card
private struct WeatherDetailCard: View {
    let weather: WeatherModel
    var isLandscape: Bool

    var body: some View {
        VStack(spacing: 18) {

            Text(weather.timezone)
                .font(.title)
                .bold()

            Text(weather.timezoneAbbreviation)
                .font(.headline)
                .foregroundColor(.secondary)

            Divider().padding(.horizontal)

            // Landscape spacing is tighter
            HStack(spacing: isLandscape ? 20 : 40) {
                WeatherMetricView(
                    value: "\(Int(weather.current.temperature2M))º",
                    label: "Temperature",
                    color: .accentColor
                )
                WeatherMetricView(
                    value: "\(weather.current.relativeHumidity2M)%",
                    label: "Humidity",
                    color: .blue
                )
                WeatherMetricView(
                    value: String(format: "%.1f", weather.current.windSpeed10M),
                    label: "Wind (m/s)",
                    color: .orange
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isLandscape ? 6 : 0)

            VStack(spacing: 2) {
                Text("Elevation: \(Int(weather.elevation)) m")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text("Updated: \(formattedDate(weather.current.time))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 7, x: 0, y: 6)
        )
        .padding(.horizontal)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        }
        return iso
    }
}


// MARK: - Weather Metric UI
private struct WeatherMetricView: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}


// MARK: - Skeleton Loader (Landscape Optimized)
private struct WeatherSkeletonCard: View {
    var isLandscape: Bool

    var body: some View {
        VStack(spacing: 18) {

            ShimmerBar(width: 180, height: 28)
            ShimmerBar(width: 90, height: 22)

            Divider().padding(.horizontal)

            HStack(spacing: isLandscape ? 18 : 40) {
                ForEach(0..<3) { _ in
                    VStack {
                        ShimmerBar(width: 44, height: 32)
                        ShimmerBar(width: 54, height: 12)
                    }
                }
            }

            VStack(spacing: 2) {
                ShimmerBar(width: 110, height: 12)
                ShimmerBar(width: 180, height: 12)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 7, x: 0, y: 6)
        )
        .padding(.horizontal)
    }
}


// MARK: - Shimmer Bar
private struct ShimmerBar: View {
    let width: CGFloat
    let height: CGFloat
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color.gray.opacity(0.18))

            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.14),
                            Color.gray.opacity(0.36),
                            Color.gray.opacity(0.14)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.white)
                            .offset(x: isAnimating ? geo.size.width : -geo.size.width)
                    }
                )
                .animation(
                    Animation.linear(duration: 1.1).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: width, height: height)
        .onAppear { isAnimating = true }
    }
}

