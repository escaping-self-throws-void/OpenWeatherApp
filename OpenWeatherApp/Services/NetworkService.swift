//
//  NetworkService.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import Foundation

protocol NetworkService {
    func fetch<T: Codable>(with endpoint: String) async throws -> T
}

extension NetworkService {
    func fetch<T: Codable>(with endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let decodedResponse = try? decoder.decode(T.self, from: data) else {
            throw NError.unableToDecode
        }
        
        return decodedResponse
    }
}
