//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter min 3 and max 7 cities"
        textField.backgroundColor = .clear
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var geoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .systemPurple
        button.addTarget(self, action: #selector(geoButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [geoButton, searchTextField])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let locationManager = CLLocationManager()
    private var weatherViewModel: WeatherViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupUI()
        setupConstraints()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        weatherViewModel = WeatherViewModel(callback: updateUI)
        dismissKeyboardOnTap()
    }
}

// MARK: - UITableView methods

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let list = weatherViewModel.getListForRow(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = weatherViewModel.getLabelText(list)
        content.secondaryText = weatherViewModel.getDescription(list)
        content.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .medium)
        content.image = UIImage(systemName: weatherViewModel.getImage(list))
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.tintColor = .systemPurple
        cell.contentView.tintColor = .systemPurple
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        var content = headerView.defaultContentConfiguration()
        
        content.text = weatherViewModel.getHeaderText()
        content.textProperties.font = .boldSystemFont(ofSize: 16)
        content.textProperties.color = .label
        
        headerView.contentConfiguration = content
        headerView.backgroundConfiguration = .clear()
        
        return headerView
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
    
    private func setupUI() {
        view.addSubviews(weatherTableView, stackView)
        view.backgroundColor = .systemBackground
        title = "Open Weather"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            geoButton.widthAnchor.constraint(equalToConstant: 40),
            geoButton.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: weatherTableView.topAnchor, constant: -5),
            
            weatherTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            weatherTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupBackgroundImage() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "bg")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.65
        view.insertSubview(imageView, at: 0)
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.weatherTableView.reloadData()
            self?.searchTextField.text = ""
            self?.isLoading(false)
        }
    }
    
    private func isLoading(_ bool: Bool) {
        var config = geoButton.configuration
        config?.showsActivityIndicator = bool
        geoButton.configuration = config
    }
    
    @objc private func geoButtonPressed() {
        isLoading(true)
        locationManager.requestLocation()
    }
    
    private func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
