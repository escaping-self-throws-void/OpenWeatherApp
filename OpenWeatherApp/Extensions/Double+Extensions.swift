//
//  Double+Extensions.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 28/09/2022.
//

import Foundation

extension Double {
    var toDateString: String {
        var strDate = "undefined"
        
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"
        
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a"
        strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}
