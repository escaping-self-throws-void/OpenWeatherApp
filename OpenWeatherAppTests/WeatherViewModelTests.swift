//
//  OpenWeatherAppTests.swift
//  OpenWeatherAppTests
//
//  Created by Paul Matar on 16/06/2022.
//

import XCTest
import CoreLocation
@testable import OpenWeatherApp

class OpenWeatherAppTests: XCTestCase, CLLocationManagerDelegate {
    
    var viewModel: WeatherViewModel?
    
    override func setUp() {
        super.setUp()
        viewModel = WeatherViewModel(locDelegate: self, closure: {})
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testDateTimeCreateWithRandomUnix() throws {
        let unix = Double.random(in: 300...600)
        let result = viewModel?.createDateTime(unix: unix)
        XCTAssertNotNil(result)
    }
    
    func testFetchWeatherWithCities() async throws {
        let citis = ["Rome", "Toronto", "Byblos"]
        let list = try await viewModel?.fetchWeather(for: citis)
        XCTAssertNotNil(list)
    }
    
    func testFetchWeatherFromGeoLocation() async throws {
        let lon = Double.random(in: 1...50)
        let lat = Double.random(in: 1...50)
        
        let data = try await viewModel?.fetchWeather(lat: lat, lon: lon)
        XCTAssertNotNil(data)
    }
    
    func testGetDescriptionFromList() async throws {
        let citis = ["Rome", "Toronto", "Byblos"]
        let list = try await viewModel?.fetchWeather(for: citis)
        let description = viewModel?.getDescription((list?.first)!)
        XCTAssertNotNil(description)
    }
    
    func testGetImageFromList() async throws {
        let citis = ["Rome", "Toronto", "Byblos"]
        let list = try await viewModel?.fetchWeather(for: citis)
        let strImage = viewModel?.getImage((list?.first)!)
        let image = UIImage(systemName: strImage!)
        XCTAssertNotNil(image)
    }
}
