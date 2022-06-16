//
//  ViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var citiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - UITableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == forecastTableView ? 5 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case forecastTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
            
            cell.textLabel?.text = "Madrid 21C Rainy --"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            
            cell.textLabel?.text = "Berlin 27C Windy ±±"
            return cell
        }
        
    }
    
}
