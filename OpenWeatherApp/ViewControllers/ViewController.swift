//
//  ViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let locationManager = CLLocationManager()
    private let ws = WeatherService()
    
    private var city: City?
    
    private var weatherList: [List] = [] {
        didSet {
            forecastTableView.reloadData()
            searchTextField.text = ""
        }
    }
    
    private var switcher = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        forecastTableView.allowsSelection = false
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func geoButtonPressed() {
        locationManager.requestLocation()
        switcher = true
    }
}

// MARK: - UITableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switcher ? city?.name : "Selected cities"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
        
        switch switcher {
        case true:
            let list = weatherList[indexPath.row]
        
            var content = cell.defaultContentConfiguration()
            content.text = ws.createDateTime(unix: list.dt)
            content.secondaryText = "\(list.main.tempMin) - \(list.main.tempMax) C " + (list.weather.first?.description ?? "undefined") + " windspeed: \(list.wind.speed)"
            
            cell.contentConfiguration = content
        default:
            let list = weatherList[indexPath.row]
            
            var content = cell.defaultContentConfiguration()
            content.text = list.name
            content.secondaryText = "\(list.main.tempMin) - \(list.main.tempMax) C " + (list.weather.first?.description ?? "undefined") + " windspeed: \(list.wind.speed)"
            
            cell.contentConfiguration = content
        }
        return cell
        
    }
    
}

// MARK: - UITextField Delegate methods

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchPressed()
        searchTextField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManager Delegate methods

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            Task {
                do {
                    let weather = try await ws.fetchWeather(lat: lat, lon: lon)
                    await MainActor.run {
                        city = weather.city
                        weatherList = weather.list
                    }
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Private methods

extension ViewController {
    
    private func searchPressed() {
        Task {
            do {
                let list = try await ws.fetchWeather(for: searchTextField.text!)
                await MainActor.run {
                    weatherList = [list]
                }
            } catch {
                print(error)
            }
        }
        switcher = false
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
