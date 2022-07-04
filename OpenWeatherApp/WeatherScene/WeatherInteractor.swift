//
//  WeatherInteractor.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 04/07/2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol WeatherBusinessLogic {
    func fetchFromGeo(request: WeatherGeoRequest)
}

protocol WeatherDataStore {
    var weatherList: [List] { get }
    var city: City? { get }
    var error: String? { get }
}

class WeatherInteractor: WeatherBusinessLogic, WeatherDataStore {
    
    var weatherList: [List] = []
    var city: City?
    var error: String?
    
    var presenter: WeatherPresentationLogic?
    
    func fetchFromGeo(request: WeatherGeoRequest) {
        if let lat = request.lat, let lon = request.lon {
            presentGeo(lat: lat, lon: lon)
        } else if let cities = request.cities {
            presentCity(with: cities)
        }
    }
}





// MARK: - Present methods

extension WeatherInteractor {
    private func presentGeo(lat: Double, lon: Double) {
        Task {
            do {
                let fetchedData = try await WeatherCoordinator.shared
                    .fetchWeather(lat: lat, lon: lon)
                city = fetchedData.city
                weatherList = fetchedData.list
            } catch let err {
                error = err.localizedDescription
            }
            
            let response = WeatherGeoResponse(city: city, weatherList: weatherList, error: error)
            presenter?.presentGeoData(response: response)
        }
    }
    
    private func presentCity(with cities: String) {
        let filteredCities = filterCities(cities)
        
        guard isValid(filteredCities.count) else {
            error = "Please enter minimum 3 and max 7 cities"
            return
        }
        
        Task {
            do {
                let list = try await WeatherCoordinator.shared.fetchWeather(for: filteredCities)
                weatherList = list
            } catch {
                self.error = error.localizedDescription
            }
            
            let response = WeatherGeoResponse(weatherList: weatherList, error: error)
            presenter?.presentGeoData(response: response)
        }
    }
}

// MARK: - Supporting methods

extension WeatherInteractor {
    private func isValid(_ num: Int) -> Bool {
        (3...7).contains(num) ? true : false
    }
    
    private func filterCities(_ cities: String) -> [String] {
        cities.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
    }
}
