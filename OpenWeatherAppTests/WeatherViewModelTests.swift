//
//  OpenWeatherAppTests.swift
//  OpenWeatherAppTests
//
//  Created by Paul Matar on 16/06/2022.
//

import XCTest
import RxSwift
import CoreLocation
@testable import OpenWeatherApp

class OpenWeatherAppTests: XCTestCase {
    
    var viewModel: WeatherViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        viewModel = WeatherViewModelMock()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testWeatherFetchServiceMock() async throws {
        let assertionOne = "San Francisco"
        let assertionTwo = "Beirut"
        let serviceMock = WeatherFetchServiceMock()
        let city: City?
        let list: [List]
        
        do {
            let weatherData = try await serviceMock.fetchWeather(lat: 0, lon: 0)
            city = weatherData.city
            list = try await serviceMock.fetchWeather(for: [])
        } catch {
            fatalError(error.localizedDescription)
        }
       
        XCTAssertEqual(city?.name, assertionOne)
        XCTAssertEqual(list.first?.name, assertionTwo)
    }
    
    func testGetGeoWeatherFailure() {
        let assertion = "Server error, try again later"
        let expectation = expectation(description: "Fetching failed")
        var errorText: String?
        let loc = CLLocation(latitude: 13, longitude: 13)
        
        viewModel?.getGeoWeather(loc, failure: { text in
            errorText = text
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)

        XCTAssertNotNil(errorText)
        XCTAssertEqual(errorText, assertion)
    }
    
    func testGetCitiesForecastFailure() {
        let assertion = "Uknown error, try again later"
        let expectation = expectation(description: "Fetching failed")
        var errorText: String?
        
        viewModel?.getCitiesForecast("Foo", failure: { text in
                errorText = text
                expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(errorText)
        XCTAssertEqual(errorText, assertion)
    }
    
    
    func testGetLabelText() {
        let assertion = "июня 24, 2:48 PM - Beirut"
        let list: List = viewModel.weatherList.value.first!
        
        let text = viewModel?.getLabelText(list)
        XCTAssertEqual(text, assertion)
    }
    
    func testGetDescription() {
        let assertion = "28 - 33 °C  Few Clouds, wind: 5.66 m/s"
        let list: List = viewModel.weatherList.value.first!
        
        let description = viewModel?.getDescription(list)
        XCTAssertEqual(description, assertion)
    }

    func testGetImage() {
        let assertion = "cloud.sun"
        let list: List = viewModel.weatherList.value.first!
        let image = viewModel?.getImage(list)
        XCTAssertEqual(image, assertion)
    }
    
    func testDateTimeCreateWithRandomUnix() {
        let assertion = "undefined"
        let mockViewModel = WeatherViewModelMock()
        let unix = Double.random(in: 300...600)
        let result = mockViewModel.createDateTime(unix: unix)
        XCTAssertNotNil(result)
        XCTAssertNotEqual(result, assertion)
    }
    
    func testIsValidMethod() {
        let assertionOne = 0
        let assertionTwo = -3
        let assertionThree = 4
        let assertionFour = 9
        
        let mockViewModel = WeatherViewModelMock()
        
        XCTAssertFalse(mockViewModel.isValid(assertionOne))
        XCTAssertFalse(mockViewModel.isValid(assertionTwo))
        XCTAssertTrue(mockViewModel.isValid(assertionThree))
        XCTAssertFalse(mockViewModel.isValid(assertionFour))
    }
    
    func testFilterCitiesMethod() {
        let assertionOne = ["FooBarBaz"]
        let assertionTwo = ["foo", "Bar", "baz"]
        let assertionThree = ["foOBarr", "Baz"]
        let assertionFour = ["FOOBarBaz"]
        
        let mockOne = "Foo Bar Baz"
        let mockTwo = "foo, Bar, baz"
        let mockThree = "foO1. Barr, Baz-2"
        let mockFour = "FOOBar  Baz"
        
        let mockViewModel = WeatherViewModelMock()

        XCTAssertEqual(mockViewModel.filterCities(mockOne), assertionOne)
        XCTAssertEqual(mockViewModel.filterCities(mockTwo), assertionTwo)
        XCTAssertEqual(mockViewModel.filterCities(mockThree), assertionThree)
        XCTAssertEqual(mockViewModel.filterCities(mockFour), assertionFour)
    }
}
