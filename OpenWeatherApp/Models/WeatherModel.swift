//
//  WeatherModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 17/06/2022.
//

import Foundation

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Temp
    let wind: Wind
    let dt: Double
    let name: String
}

