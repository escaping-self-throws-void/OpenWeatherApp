//
//  WeatherData.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 17/06/2022.
//

import Foundation

struct WeatherData: Codable {
    let list: [List]
    let city: City
}

struct City: Codable {
    let id: Int
    let name: String
    let country: String
}

struct List: Codable {
    let dt: Double
    let main: Temp
    let weather: [Weather]
    let wind: Wind
    let name: String?
}

struct Temp: Codable {
    let tempMin, tempMax: Double
}


struct Weather: Codable {
    let description: String
}

struct Wind: Codable {
    let speed: Double
}
