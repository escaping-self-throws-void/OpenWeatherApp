//
//  WeatherViewModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import Foundation
import CoreLocation

protocol WeatherViewModelProtocol: WeatherFetchService {
    init(callback: @escaping () -> Void)
    var weatherList: [List] { get set }
    
    func getLabelText(_ list: List) -> String?
    func getDescription(_ list: List) -> String
    func getImage(_ list: List) -> String
    func getHeaderText() -> String?
    
    func getGeoWeather(_ loc: CLLocation?, failure: @escaping (String) -> Void)
    func getCitiesForecast(_ city: String?, failure: @escaping (String) -> Void)
}

final class WeatherViewModel: WeatherViewModelProtocol {
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    var weatherList: [List] = [] {
        didSet {
            callback()
        }
    }
    
    private var callback: (() -> Void)
    private var city: City?
    private var switcher = true
}
    
// MARK: - Fetching methods

extension WeatherViewModel {
    func getGeoWeather(_ loc: CLLocation?, failure: @escaping (String) -> Void) {
        guard let location = loc else {
            failure("Can not access location")
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        Task {
            do {
                let weather = try await fetchWeather(lat: lat, lon: lon)
                city = weather.city
                weatherList = weather.list
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
        switcher = true
    }
    
    func getCitiesForecast(_ input: String?, failure: @escaping (String) -> Void) {
        guard let input = input else { return }
        let cities = input.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
        
        guard (3...7).contains(cities.count) else {
            failure("Please enter minimum 3 and max 7 cities")
            return
        }
        
        Task {
            do {
                let list = try await fetchWeather(for: cities)
                weatherList = list
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
        switcher = false
    }
}

// MARK: - TableView methods

extension WeatherViewModel {

    func getLabelText(_ list: List) -> String? {
        switcher ? list.dt.toDateString : list.name
    }
    
    func getHeaderText() -> String? {
        switcher ? city?.name : weatherList.first?.dt.toDateString
    }
    
    func getDescription(_ list: List) -> String {
        let minT = String(format: "%1.f", list.main.tempMin)
        let maxT = String(format: "%1.f", list.main.tempMax)
        let info = list.weather.first?.description ?? "undefined"
        let wSpeed = list.wind.speed
        let description = "\(minT) - \(maxT) °C  \(info.capitalized), wind: \(wSpeed) m/s"
        return description
    }
    
    func getImage(_ list: List) -> String {
        let code = list.weather.first?.id ?? 0
        
        switch code {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...780:
            return "cloud.fog"
        case 781:
            return "tornado"
        case 800:
            return "sun.max"
        case 803...804:
            return "cloud"
        default:
            return "cloud.sun"
        }
    }
}
