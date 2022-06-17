//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let locationManager = CLLocationManager()
    private let ws = WeatherViewModel()
    private var city: City?
    private var switcher = true
    
    private var weatherList: [List] = [] {
        didSet {
            weatherTableView.reloadData()
            searchTextField.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        weatherTableView.keyboardDismissMode = .onDrag
        weatherTableView.allowsSelection = false
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func geoButtonPressed() {
        locationManager.requestLocation()
        switcher = true
    }
}

// MARK: - UITableView methods

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switcher ? city?.name : ws.createDateTime(unix: weatherList.first?.dt)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath)
        let list = weatherList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = switcher ? ws.createDateTime(unix: list.dt) : list.name
        content.secondaryText = "\(list.main.tempMin) - \(list.main.tempMax) C " + (list.weather.first?.description ?? "undefined") + " windspeed: \(list.wind.speed)"
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITextField Delegate methods

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchPressed()
        searchTextField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManager Delegate methods

extension WeatherViewController: CLLocationManagerDelegate {
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

extension WeatherViewController {
    
    private func searchPressed() {
        Task {
            do {
                let list = try await ws.fetchWeather(for: searchTextField.text!)
                await MainActor.run {
                    weatherList = list
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
