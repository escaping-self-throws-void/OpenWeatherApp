//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 18/06/2022.
//

import Foundation

final class WeatherWorker: NetworkService {
    
    static let shared = WeatherWorker()
    
    private var baseURL: String {
        "https://api.openweathermap.org/data/2.5/weather?units=metric&"
    }
    private var apiKey: String {
        "appid=7f6824a9a416eabb078fbb2892379766"
    }
    private var forecastURL: String {
        "https://api.openweathermap.org/data/2.5/forecast?units=metric&"
    }
    
    private init() {}
    
    func fetchWeather(for cities: [String]) async throws -> [List] {
        var lists: [List] = []
        
        for city in cities {
            let stringUrl = baseURL + apiKey + "&q=\(city)"
            async let list: List = fetch(with: stringUrl)
            lists += [try await list]
        }
        return lists
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherData {
        let stringUrl = forecastURL + apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
}

