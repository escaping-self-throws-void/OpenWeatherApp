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
    
    private var vm: WeatherViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = WeatherViewModel(service: WeatherService(), locDelegate: self, closure: updateUI)
        addKeyboardDismiss()
        weatherTableView.allowsSelection = false
    }

    @IBAction func geoButtonPressed() {
        vm.requestLocation()
    }
}

// MARK: - UITableView methods

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.weatherList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        vm.switcher ? vm.city?.name : vm.createDateTime(unix: vm.weatherList.first?.dt)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let list = vm.weatherList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = vm.switcher ? vm.createDateTime(unix: list.dt) : list.name
        content.secondaryText = vm.getDescription(list)
        content.image = UIImage(systemName: vm.getImage(list))
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
        vm.getGeoWeather(from: locations.last) { [weak self] errorText in
            DispatchQueue.main.async {
                self?.showAlert(errorText)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - UIAlertController

extension WeatherViewController {
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - Private methods

extension WeatherViewController {
    
    private func searchPressed() {
        vm.getCitiesForecast(searchTextField.text) { [weak self] errorText in
            DispatchQueue.main.async {
                self?.showAlert(errorText)
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.weatherTableView.reloadData()
            self?.searchTextField.text = ""
        }
    }
    
    private func addKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        weatherTableView.keyboardDismissMode = .onDrag
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
