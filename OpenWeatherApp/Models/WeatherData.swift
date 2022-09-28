//
//  WeatherData.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 17/06/2022.
//

import Foundation

struct WeatherData: Codable, Hashable {
    let list: [List]
    let city: City
}

struct City: Codable, Hashable {
    let id: Int
    let name: String
    let country: String
}

struct List: Codable, Hashable {
    let dt: Double
    let main: Temp
    let weather: [Weather]
    let wind: Wind
    let name: String?
}

struct Temp: Codable, Hashable {
    let tempMin, tempMax: Double
}


struct Weather: Codable, Hashable {
    let description: String
    let id: Int
}

struct Wind: Codable, Hashable {
    let speed: Double
}
