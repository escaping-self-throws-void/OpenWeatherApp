//
//  MockableService.swift
//  OpenWeatherAppTests
//
//  Created by Paul Matar on 24/06/2022.
//

import Foundation

protocol MockableService: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String) -> T
}

extension MockableService {
    var bundle: Bundle {
        Bundle(for: type(of: self))
    }
    
    func loadJSON<T:Decodable>(filename: String) -> T {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }
        
        do {
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try decoder.decode(T.self, from: data)
            
            return decodedObject
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
