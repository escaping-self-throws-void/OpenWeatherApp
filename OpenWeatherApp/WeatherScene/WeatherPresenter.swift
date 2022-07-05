//
//  WeatherPresenter.swift
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

protocol WeatherPresentationLogic {
    func presentData(response: WeatherResponse)
}

final class WeatherPresenter: WeatherPresentationLogic {
    
    weak var viewController: WeatherDisplayLogic?
    
    func presentData(response: WeatherResponse) {
        let switcher = response.city != nil
        let headerText = switcher ? response.city?.name : createDateTime(unix: response.weatherList.first?.dt)
        let error = response.error
        
        var cells = [WeatherCell]()
        
        response.weatherList.forEach { list in
            let label = switcher ? createDateTime(unix: list.dt) : list.name
            let description = getDescription(list)
            let image = getImage(list)
            let cell = WeatherCell(labelText: label,
                                      description: description,
                                      image: image)
            cells.append(cell)
        }
        
        let viewModel = WeatherViewModel(cells: cells,
                                            headerText: headerText,
                                            error: error)
        viewController?.displayWeather(viewModel: viewModel)
    }
    
    
}

// MARK: - Supporting methods

extension WeatherPresenter {
    private func getDescription(_ list: List) -> String {
        let minT = String(format: "%1.f", list.main.tempMin)
        let maxT = String(format: "%1.f", list.main.tempMax)
        let info = list.weather.first?.description ?? "undefined"
        let wSpeed = list.wind.speed
        let description = "\(minT) - \(maxT) °C  \(info.capitalized), wind: \(wSpeed) m/s"
        return description
    }
    
    private func getImage(_ list: List) -> String {
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
}
