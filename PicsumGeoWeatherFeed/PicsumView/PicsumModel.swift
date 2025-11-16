//
//  PicsumModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//

struct PicsumModel: Codable, Identifiable{
    var format: String
    var width: Int
    var height: Int
    var filename: String
    var id: Int
    var author: String
    var author_url: String
    var post_url: String
}
