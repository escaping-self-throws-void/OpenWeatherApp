//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import Foundation

protocol WeatherServicable {
    func fetchWeather(for city: String) -> WeatherModel?
}

struct WeatherService: WeatherServicable, NetworkService {
    func fetchWeather(for city: String) -> WeatherModel? {
        let stringUrl = K.baseURL + K.apiKey + "&q=" + city
        guard let url = URL(string: stringUrl) else {
            return nil
        }
        
        
        
        return nil
    }
    
    
    
}
