//
//  UIViewController+Extensions.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 28/09/2022.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
