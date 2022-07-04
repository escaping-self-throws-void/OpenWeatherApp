//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var geoButton: UIButton!
    
    private let locationManager = CLLocationManager()
    private var weatherViewModel: WeatherViewModelProtocol!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        weatherViewModel = WeatherViewModel()
        setupBackgroundImage()
        dismissKeyboardOnTap()
        bindTableView()
    }
    
    @IBAction func geoButtonPressed() {
        isLoading(true)
        locationManager.requestLocation()
    }
}

// MARK: - UITableView methods

extension WeatherViewController {
    
    private func bindTableView() {
        weatherViewModel.weatherList
            .bind(to: weatherTableView.rx.items(cellIdentifier: "WeatherCell", cellType: UITableViewCell.self)) { [weak self] row, model, cell in
            var content = cell.defaultContentConfiguration()
            
            content.text = self?.weatherViewModel.getLabelText(model)
            content.secondaryText = self?.weatherViewModel.getDescription(model)
            content.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .medium)
            let image = self?.weatherViewModel.getImage(model)
            content.image = UIImage(systemName: image ?? "cloud.sun")
            cell.contentConfiguration = content
            cell.backgroundColor = .clear
        }.disposed(by: bag)
        
        weatherViewModel.weatherList.subscribe { _ in
            self.updateUI()
        }.disposed(by: bag)

    }
}

// MARK: - UITextField Delegate methods

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weatherViewModel.getCitiesForecast(searchTextField.text) { [weak self] errorText in
            DispatchQueue.main.async {
                self?.showAlert(errorText)
            }
        }
        searchTextField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManager Delegate methods

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        weatherViewModel.getGeoWeather(locations.last) { [weak self] errorText in
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
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            self?.isLoading(false)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - Private methods

extension WeatherViewController {
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.searchTextField.text = ""
            self?.isLoading(false)
        }
    }
    
    private func setupBackgroundImage() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "bg")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.65
        view.insertSubview(imageView, at: 0)
        searchTextField.backgroundColor = .clear
        weatherTableView.backgroundColor = .clear
        weatherTableView.allowsSelection = false
    }
    
    private func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func isLoading(_ bool: Bool) {
        var config = geoButton.configuration
        config?.showsActivityIndicator = bool
        geoButton.configuration = config
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
