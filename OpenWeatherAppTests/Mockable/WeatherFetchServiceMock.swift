//
//  MockableService.swift
//  OpenWeatherAppTests
//
//  Created by Paul Matar on 24/06/2022.
//

import CoreLocation
@testable import OpenWeatherApp

class WeatherFetchServiceMock: WeatherWorker, MockableService {
    func fetchWeather(for cities: [String]) async throws -> [List] {
        if cities.first == "Foo" {
            throw NError.unknown
        }
        let list: List = loadJSON(filename: "cities")
        return [list]
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData {
        if lat == 13, lon == 13 {
            throw NError.invalidData
        }
        let data: WeatherData = loadJSON(filename: "location")
        return data
    }
}

