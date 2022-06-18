//
//  WeatherViewModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import CoreLocation
import UIKit


final class WeatherViewModel {
    private(set) var weatherList: [List] = [] {
        didSet {
            closure()
        }
    }
    private(set) var city: City?
    private(set) var switcher = true
    private let locationManager = CLLocationManager()
    
    private let service: WeatherServicable
    private var closure: (() -> Void)
    
    init(service: WeatherServicable, locDelegate: CLLocationManagerDelegate, closure: @escaping () -> Void) {
        self.service = service
        self.closure = closure
        locationManager.delegate = locDelegate
        locationManager.requestWhenInUseAuthorization()
    }
}
    
// MARK: - Fetching methods

extension WeatherViewModel {
    func getGeoWeather(from location: CLLocation?, failure: @escaping (String) -> Void) {
        guard let location = location else {
            failure("Can not access location")
            return
        }
        
        locationManager.stopUpdatingLocation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        Task {
            do {
                let weather = try await service.fetchWeather(lat: lat, lon: lon)
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
        guard let cities = input else { return }
        let filteredCities = filterCities(cities)
        
        guard isValid(filteredCities.count) else {
            failure("Plese enter minimum 3 and max 7 cities")
            return
        }
        
        Task {
            do {
                let list = try await service.fetchWeather(for: filteredCities)
                weatherList = list
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
        switcher = false
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - Processing methods

extension WeatherViewModel {
    func getDescription(_ list: List) -> String {
        let minT = String(format: "%1.f", list.main.tempMin)
        let maxT = String(format: "%1.f", list.main.tempMax)
        let info = list.weather.first?.description ?? "undefined"
        let wSpeed = list.wind.speed
        let description = "\(minT) - \(maxT) °C  \(info) windspeed: \(wSpeed)"
        return description
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
}

// MARK: - Supporting methods

extension WeatherViewModel {
    private func isValid(_ num: Int) -> Bool {
        (3...7).contains(num) ? true : false
    }
    
    private func filterCities(_ cities: String) -> [String] {
        cities.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
    }
}
