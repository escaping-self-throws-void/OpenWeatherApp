//
//  WeatherModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import Foundation

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String
}

struct Weather: Codable {
    let description: String
}

struct Main: Codable {
    let minTemp: Double
    let maxTemp: Double
    
    enum CodingKeys: String, CodingKey {
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
    }
}

struct Wind: Codable {
    let speed: Double
}
