//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 18/06/2022.
//

import Foundation

//protocol WeatherCoordinator: NetworkService {
//    func fetchWeather(for cities: [String]) async throws -> [List]
//    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherData
//}

final class WeatherCoordinator: NetworkService {
    
    static let shared = WeatherCoordinator()
    
    
    private var baseURL: String {
        "https://api.openweathermap.org/data/2.5/weather?units=metric&"
    }
    private var apiKey: String {
        "appid=7f6824a9a416eabb078fbb2892379766"
    }
    private var forecastURL: String {
        "https://api.openweathermap.org/data/2.5/forecast?units=metric&"
    }
    
    private init() {}
    
    func fetchWeather(for cities: [String]) async throws -> [List] {
        var lists: [List] = []
        
        for city in cities {
            let stringUrl = baseURL + apiKey + "&q=\(city)"
            async let list: List = fetch(with: stringUrl)
            lists += [try await list]
        }
        return lists
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherData {
        let stringUrl = forecastURL + apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
    
//    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, NError>) -> Void ) {
//        let stringUrl = forecastURL + apiKey + "&lat=\(lat)&lon=\(lon)"
//        guard let url = URL(string: stringUrl) else {
//            completion(.failure(.invalidURL))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                completion(.failure(NError.invalidResponse))
//                return
//            }
//
//            guard let data = data, error == nil else {
//                completion(.failure(NError.invalidData))
//                return
//            }
//
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            do {
//                let jsonData = try decoder.decode(WeatherData.self, from: data)
//                completion(.success(jsonData))
//            } catch {
//                completion(.failure(NError.unableToDecode))
//            }
//        }.resume()
//
//    }
}


