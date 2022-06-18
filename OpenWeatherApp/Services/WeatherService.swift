//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 18/06/2022.
//

import CoreLocation

protocol WeatherServicable {
    func fetchWeather(for cities: [String]) async throws -> [List]
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData
}

struct WeatherService: WeatherServicable, NetworkService {
    func fetchWeather(for cities: [String]) async throws -> [List] {
        var lists: [List] = []
        
        for city in cities {
            let stringUrl = Url.baseURL + Url.apiKey + "&q=\(city)"
            async let list: List = fetch(with: stringUrl)
            lists += [try await list]
        }
        
        return lists
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData {
        let stringUrl = Url.forecastURL + Url.apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
    
    private enum Url {
        static let apiKey = "appid=7f6824a9a416eabb078fbb2892379766"
        static let baseURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&"
        static let forecastURL = "https://api.openweathermap.org/data/2.5/forecast?units=metric&"
    }
}
