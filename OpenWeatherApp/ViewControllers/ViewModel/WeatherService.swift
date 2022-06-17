//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import CoreLocation


struct WeatherService: NetworkService {
    func fetchWeather(for city: String) async throws -> List {
        let stringUrl = K.baseURL + K.apiKey + "&q=\(city)"
        print(stringUrl)
        return try await fetch(with: stringUrl)
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> ForecastModel {
        let stringUrl = K.forecastURL + K.apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
    
    func createDateTime(unix: Double) -> String {
        var strDate = "undefined"
        
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"
        
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}
