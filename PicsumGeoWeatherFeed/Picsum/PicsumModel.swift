//
//  PicsumModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

struct PicsumModel: Codable, Identifiable {
    var format: String
    var width: Int
    var height: Int
    var filename: String
    var id: Int
    var author: String
    var authorUrl: String
    var postUrl: String

    enum CodingKeys: String, CodingKey {
        case format
        case width
        case height
        case filename
        case id
        case author
        case authorUrl = "author_url"
        case postUrl = "post_url"
    }
}
