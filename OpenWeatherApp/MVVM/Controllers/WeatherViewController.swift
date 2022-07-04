//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Paul Matar on 16/06/2022.
//

import UIKit
import CoreLocation

protocol WeatherDisplayLogic: AnyObject {
    func displayWeather(viewModel: WeatherViewModel)
}

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var geoButton: UIButton!
    
    var interactor: WeatherBusinessLogic?
    
    private let locationManager = CLLocationManager()
    private var weatherViewModel: WeatherViewModel? {
        didSet {
            updateUI()
            showError()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        setupBackgroundImage()
        dismissKeyboardOnTap()
    }
    
    @IBAction func geoButtonPressed() {
        isLoading(true)
        locationManager.requestLocation()
    }
}

// MARK: - UITableView methods

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherViewModel?.cells.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let cellModel = weatherViewModel?.cells[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = cellModel?.labelText
        content.secondaryText = cellModel?.description
        content.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .medium)
        content.image = UIImage(systemName: cellModel!.image)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        var content = headerView.defaultContentConfiguration()
        
        content.text = weatherViewModel?.headerText
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
        getCityWeatherList(searchTextField.text)
        searchTextField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManager Delegate methods

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.last else {
            showAlert("Can not access location")
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        getGeoWeatherList(lat, lon: lon)
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
    
    private func showError() {
        if let error = weatherViewModel?.error {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(error)
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.weatherTableView.reloadData()
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

// MARK: - Clean Swift

extension WeatherViewController {
    
    private func setup() {
        let viewController = self
        let interactor = WeatherInteractor()
        let presenter = WeatherPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    private func getGeoWeatherList(_ lat: Double, lon: Double) {
        let request = WeatherRequest(lat: lat, lon: lon)
        interactor?.fetchFrom(request: request)
    }
    
    private func getCityWeatherList(_ cities: String?) {
        let request = WeatherRequest(cities: cities)
        interactor?.fetchFrom(request: request)
    }
}

extension WeatherViewController: WeatherDisplayLogic {
    func displayWeather(viewModel: WeatherViewModel) {
        weatherViewModel = viewModel
    }
}

