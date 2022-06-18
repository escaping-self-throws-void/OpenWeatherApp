//
//  WeatherViewModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import CoreLocation
import UIKit


final class WeatherViewModel: NetworkService {
    
    func fetchWeather(for cities: String) async throws -> [List] {
        let filteredCities = cities.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
        if !isValid(filteredCities.count) {
            fatalError("Wrong number of cities")
        }
        var lists: [List] = []
        
        for i in filteredCities {
            let stringUrl = K.baseURL + K.apiKey + "&q=\(i)"
            async let list: List = fetch(with: stringUrl)
            lists += [try await list]
        }
        
        return lists
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData {
        let stringUrl = K.forecastURL + K.apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
    
    func createDateTime(unix: Double?) -> String {
        var strDate = "undefined"
        guard let unix = unix else { return strDate }
        
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"
        
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    private func isValid(_ num: Int) -> Bool {
        (3...7).contains(num) ? true : false
    }
    

}
