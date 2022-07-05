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
import Foundation

protocol WeatherBusinessLogic {
    func getData(from request: WeatherRequest)
}

protocol WeatherDataStore {
    var weatherList: [List] { get }
    var city: City? { get }
    var error: String? { get }
}

final class WeatherInteractor: WeatherBusinessLogic, WeatherDataStore {
    var weatherList: [List] = []
    var city: City?
    var error: String?
    
    var presenter: WeatherPresentationLogic?
    
    func getData(from request: WeatherRequest) {
        if let lat = request.lat, let lon = request.lon {
            presentGeo(lat: lat, lon: lon)
        } else if let cities = request.cities {
            presentCity(with: cities)
        }
    }
}

// MARK: - Presenting methods

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
            
            let response = WeatherResponse(city: city, weatherList: weatherList, error: error)
            presenter?.presentData(response: response)
        }
    }
    
    private func presentCity(with cities: String) {
        let filteredCities = filterCities(cities)
        
        guard isValid(filteredCities.count) else {
            error = "Please enter minimum 3 and max 7 cities"
            let response = WeatherResponse(weatherList: weatherList, error: error)
            presenter?.presentData(response: response)
            return
        }
        
        Task {
            do {
                let list = try await WeatherCoordinator.shared.fetchWeather(for: filteredCities)
                weatherList = list
            } catch {
                self.error = error.localizedDescription
            }
            
            let response = WeatherResponse(weatherList: weatherList, error: error)
            presenter?.presentData(response: response)
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