//
//  NError.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 18/06/2022.
//

import Foundation

enum NError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToDecode
    case unknown
}

extension NError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidURL:
            return "Bad URL"
        case .invalidResponse:
            return "The server did not return 200"
        case .invalidData:
            return "Bad data returned"
        case .unableToDecode:
            return "Unable to decode JSON"
        case .unknown:
            return "Unknown error"
        }
    }
}

extension NError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Server error, try again later"
        case .unknown:
            return "Uknown error, try again later"
        default:
            return "Wrong city names"
        }
    }
}
