//
//  WeatherViewModel.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

protocol WeatherViewModelProtocol: WeatherFetchService {
    var weatherList: BehaviorRelay<[List]> { get }
    
    func getLabelText(_ list: List) -> String?
    func getDescription(_ list: List) -> String
    func getImage(_ list: List) -> String
    
    func getGeoWeather(_ loc: CLLocation?, failure: @escaping (String) -> Void)
    func getCitiesForecast(_ city: String?, failure: @escaping (String) -> Void)
}

final class WeatherViewModel: WeatherViewModelProtocol {
 
    var weatherList = BehaviorRelay<[List]>(value: [])

    private var city: City?
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
                weatherList.accept(weather.list)
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
    }
    
    func getCitiesForecast(_ city: String?, failure: @escaping (String) -> Void) {
        guard let cities = city else { return }
        let filteredCities = filterCities(cities)
        
        guard isValid(filteredCities.count) else {
            failure("Please enter minimum 3 and max 7 cities")
            return
        }
        
        Task {
            do {
                let list = try await fetchWeather(for: filteredCities)
                weatherList.accept(list)
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
    }
}

// MARK: - TableView methods

extension WeatherViewModel {
    
    func getLabelText(_ list: List) -> String? {
        let name = list.name != nil ? list.name : city?.name
        return "\(createDateTime(unix: list.dt)) - \(name ?? "undefined")"
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

// MARK: - Supporting methods

extension WeatherViewModel {
    private func createDateTime(unix: Double?) -> String {
        var strDate = "undefined"
        guard let unix = unix else { return strDate }
        
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"
        
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a"
        strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    private func isValid(_ num: Int) -> Bool {
        (3...7).contains(num) ? true : false
    }
    
    private func filterCities(_ cities: String) -> [String] {
        cities.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
    }
}
