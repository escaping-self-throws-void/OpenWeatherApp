# Open Weather App
![weather-app](https://user-images.githubusercontent.com/24648375/174482761-9096c4fd-537d-4e98-9a03-3a4ddf9b0996.png)



Small app to fetch the weather forecast of multiple cities.

## Description


### Home Screen
* Clean and minimalistic UI.
* Searchbox on top for cities input and geobutton for requesting current user's location.
* Fetching weather info from openweathermap.org.

![Simulator Screen Shot - iPhone 13 Pro - 2022-06-19 at 13 47 57](https://user-images.githubusercontent.com/24648375/174477284-85728f2e-d5f1-4b60-a39b-d8236c5a79cd.png)

### Search multiple cities
* The app accepts multiple city names from the user(comma separated) and display following attributes using API to fetch current temperatures: • temperature (min and max) • weather (description) • wind speed
* User should enter minimum 3 cities and max 7 citiees. 
* Alerts will pop up in case of wrong input.
* The list returns in order of user's query input.

![Simulator Screen Shot - iPhone 13 Pro - 2022-06-19 at 13 50 05](https://user-images.githubusercontent.com/24648375/174477508-96abe1b2-bf38-4dcb-a627-3d731c9fd396.png)


### Find the current city using GPS
* App displays the weather forecast for the current city in a list with mentioned attributes for 5 days 3 hours.
* The icons reflect the weather conditions and change dynamically .

![Simulator Screen Shot - iPhone 13 Pro - 2022-06-19 at 13 52 31](https://user-images.githubusercontent.com/24648375/174477516-76d2f553-48fe-4de3-aab9-b79e89d8a207.png)

## Tools used

### Language and framework

* Swift 
* UIKit

### Design Pattern

* MVVM 
* CleanSwift (other branch)

### Concepts

* SOLID
* OOP
* POP
* Dependency injection

### Dependencies

* RxSwift (other branch)

## In-depth 

### Model 

Codable model used to decode from JSON.

```Swift
struct WeatherData: Codable {
    let list: [List]
    let city: City
}
...
```
### Generic Async/Await Network Layer

Protocol Network Service with default implementation in extension using generic type, URLSession and async/await, introduced in Swift 5.5.

```Swift
protocol NetworkService {
    func fetch<T: Codable>(with endpoint: String) async throws -> T
}

extension NetworkService {
    func fetch<T: Codable>(with endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let decodedResponse = try? decoder.decode(T.self, from: data) else {
            throw NError.unableToDecode
        }
        
        return decodedResponse
    }
}
```

Custom network ErrorType with custom internal description.

```Swift
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
```

And with custom localized description to show in alerts for user.

```Swift
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
```

### Weather Fetch Service

Protocol service confirming to Network Service protocol to fetch data from API with two methods - from input text and CLLocation.

```Swift
protocol WeatherFetchService: NetworkService {
    func fetchWeather(for cities: [String]) async throws -> [List]
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData
}
```
Default implementation in extension with encapsulated url and apiKey.

```Swift
extension WeatherFetchService {
    private var baseURL: String {
        "https://api.openweathermap.org/data/2.5/weather?units=metric&"
    }
    private var apiKey: String {
        "appid=MyApiKey"
    }
    private var forecastURL: String {
        "https://api.openweathermap.org/data/2.5/forecast?units=metric&"
    }
    
    func fetchWeather(for cities: [String]) async throws -> [List] {
        var lists: [List] = []
        
        for city in cities {
            let stringUrl = baseURL + apiKey + "&q=\(city)"
            async let list: List = fetch(with: stringUrl)
            lists += [try await list]
        }
        
        return lists
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData {
        let stringUrl = forecastURL + apiKey + "&lat=\(lat)&lon=\(lon)"
        return try await fetch(with: stringUrl)
    }
}
```
### View Model

Weather View Model protocol as a public interface confirming to Weather Fetch Service.

```Swift
protocol WeatherViewModelProtocol: WeatherFetchService {
    init(callback: @escaping () -> Void)
    
    func numberOfRows() -> Int
    func getListForRow(at indexPath: IndexPath) -> List
    
    func getLabelText(_ list: List) -> String?
    func getDescription(_ list: List) -> String
    func getImage(_ list: List) -> String
    func getHeaderText() -> String?
    
    func getGeoWeather(_ loc: CLLocation?, failure: @escaping (String) -> Void)
    func getCitiesForecast(_ city: String?, failure: @escaping (String) -> Void)
}
```
Weather View Model final class with implementation of protocol methods.

```Swift
final class WeatherViewModel: WeatherService {
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
```

Observable internal Model with closure to update UI.

```Swift
    private var callback: (() -> Void)
    
    private var weatherList: [List] = [] {
        didSet {
            callback()
        }
    }  
    private var city: City?
```
Boolean property to show different data in the same Table View.

```Swift
    private var switcher = true
```
Fetching methods to update internal Model.

```Swift
extension WeatherViewModel {
    func getGeoWeather(_ loc: CLLocation?, failure: @escaping (String) -> Void) {
        guard let location = loc else {
            failure("Can not access location")
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        Task {
            do {
                let weather = try await fetchWeather(lat: lat, lon: lon)
                city = weather.city
                weatherList = weather.list
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
        switcher = true
    }
    
    func getCitiesForecast(_ city: String?, failure: @escaping (String) -> Void) {
        guard let cities = city else { return }
        let filteredCities = filterCities(cities)
        
        guard isValid(filteredCities.count) else {
            failure("Plese enter minimum 3 and max 7 cities")
            return
        }
        
        Task {
            do {
                let list = try await fetchWeather(for: filteredCities)
                weatherList = list
            } catch {
                print(error)
                failure(error.localizedDescription)
            }
        }
        switcher = false
    }
}
```
Methods to provide data for the Table View and View Controller.

```Swift
extension WeatherViewModel {
    func numberOfRows() -> Int {
        weatherList.count
    }
    
    func getListForRow(at indexPath: IndexPath) -> List {
        weatherList[indexPath.row]
    }
    
    func getLabelText(_ list: List) -> String? {
        switcher ? createDateTime(unix: list.dt) : list.name
    }
    
    func getHeaderText() -> String? {
        switcher ? city?.name : createDateTime(unix: weatherList.first?.dt)
    }
    
    func getDescription(_ list: List) -> String {
        let minT = String(format: "%1.f", list.main.tempMin)
        let maxT = String(format: "%1.f", list.main.tempMax)
        let info = list.weather.first?.description ?? "undefined"
        let wSpeed = list.wind.speed
        let description = "\(minT) - \(maxT) °C  \(info.capitalized), wind: \(wSpeed) m/s"
        return description
    }
    
    func getImage(_ list: List) -> String {
        let code = list.weather.first?.id ?? 0
        
        switch code {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...780:
            return "cloud.fog"
        case 781:
            return "tornado"
        case 800:
            return "sun.max"
        case 803...804:
            return "cloud"
        default:
            return "cloud.sun"
        }
    }
}
```

Supporting private methods for formatting and text validation of Text Field input.

```Swift    
extension WeatherViewModel {
    private func createDateTime(unix: Double?) -> String {
        var strDate = "undefined"
        guard let unix = unix else { return strDate }
        
        let date = Date(timeIntervalSince1970: unix)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"
        
        dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a"
        strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    private func isValid(_ num: Int) -> Bool {
        (3...7).contains(num) ? true : false
    }
    
    private func filterCities(_ cities: String) -> [String] {
        cities.filter { $0 == "," || $0.isLetter }.components(separatedBy: ",")
    }
}
```



### Unit testing

Mockable protocol to test network layer with loadJSON function, which reads an internal .json files and converts them into Codable Model.

<img width="300" alt="Screen Shot 2022-06-24 at 8 33 16 PM" src="https://user-images.githubusercontent.com/24648375/175613189-cacb60ab-b040-4232-8135-77204ba514fb.png">


```Swift
class WeatherFetchServiceMock: WeatherFetchService, MockableService {
    func fetchWeather(for cities: [String]) async throws -> [List] {
        if cities.first == "Foo" {
            throw NError.unknown
        }
        let list: List = loadJSON(filename: "cities")
        return [list]
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherData {
        if lat == 13, lon == 13 {
            throw NError.invalidData
        }
        let data: WeatherData = loadJSON(filename: "location")
        return data
    }
}
```


View Model unit testing with Mock View Model confirming to Weather View Model protocol. 

```Swift
class OpenWeatherAppTests: XCTestCase {
    
    var viewModel: WeatherViewModelProtocol?
    var list: List {
        let indexPath = IndexPath(row: 0, section: 0)
        let listForRow = viewModel?.getListForRow(at: indexPath)
        return listForRow!
    }
    func mockCallback() {}
    
    override func setUp() {
        super.setUp()
        viewModel = WeatherViewModelMock(callback: mockCallback)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testWeatherFetchServiceMock() async throws {
        let assertionOne = "San Francisco"
        let assertionTwo = "Beirut"
        let serviceMock = WeatherFetchServiceMock()
        let city: City?
        let list: [List]
        
        do {
            let weatherData = try await serviceMock.fetchWeather(lat: 0, lon: 0)
            city = weatherData.city
            list = try await serviceMock.fetchWeather(for: [])
        } catch {
            fatalError(error.localizedDescription)
        }
       
        XCTAssertEqual(city?.name, assertionOne)
        XCTAssertEqual(list.first?.name, assertionTwo)
    }
    
    func testGetGeoWeatherFailure() {
        let assertion = "Server error, try again later"
        let expectation = expectation(description: "Fetching failed")
        var errorText: String?
        let loc = CLLocation(latitude: 13, longitude: 13)
        
        viewModel?.getGeoWeather(loc, failure: { text in
            errorText = text
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)

        XCTAssertNotNil(errorText)
        XCTAssertEqual(errorText, assertion)
    }
    
    func testGetCitiesForecastFailure() {
        let assertion = "Uknown error, try again later"
        let expectation = expectation(description: "Fetching failed")
        var errorText: String?
        
        viewModel?.getCitiesForecast("Foo", failure: { text in
                errorText = text
                expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(errorText)
        XCTAssertEqual(errorText, assertion)
    }
    
    func testNumberOfRows() {
        let assertion = 1
        let rows = viewModel?.numberOfRows()
        XCTAssertEqual(rows, assertion)
    }
    
    func testGetListForRow() throws {
        let assertion = "Beirut"
        let indexPath = IndexPath(row: 0, section: 0)
        
        let list = viewModel?.getListForRow(at: indexPath)

        XCTAssertNotNil(list)
        XCTAssertEqual(list?.name, assertion)
    }
    
    func testGetLabelText() {
        let assertion = "Jun 24, 2:48 PM"
        let text = viewModel?.getLabelText(list)
        XCTAssertEqual(text, assertion)
    }
    
    func testGetHeaderText() {
        let assertion = "San Francisco"
        let headerText = viewModel?.getHeaderText()
        XCTAssertEqual(headerText, assertion)
    }
    
    func testGetDescription() {
        let assertion = "28 - 33 °C  Few Clouds, wind: 5.66 m/s"
        let description = viewModel?.getDescription(list)
        XCTAssertEqual(description, assertion)
    }
    
    func testGetImage() {
        let assertion = "cloud.sun"
        let image = viewModel?.getImage(list)
        XCTAssertEqual(image, assertion)
    }
    
    func testDateTimeCreateWithRandomUnix() {
        let assertion = "undefined"
        let mockViewModel = WeatherViewModelMock(callback: mockCallback)
        let unix = Double.random(in: 300...600)
        let result = mockViewModel.createDateTime(unix: unix)
        XCTAssertNotNil(result)
        XCTAssertNotEqual(result, assertion)
    }
    
    func testIsValidMethod() {
        let assertionOne = 0
        let assertionTwo = -3
        let assertionThree = 4
        let assertionFour = 9
        
        let mockViewModel = WeatherViewModelMock(callback: mockCallback)
        
        XCTAssertFalse(mockViewModel.isValid(assertionOne))
        XCTAssertFalse(mockViewModel.isValid(assertionTwo))
        XCTAssertTrue(mockViewModel.isValid(assertionThree))
        XCTAssertFalse(mockViewModel.isValid(assertionFour))
    }
    
    func testFilterCitiesMethod() {
        let assertionOne = ["FooBarBaz"]
        let assertionTwo = ["foo", "Bar", "baz"]
        let assertionThree = ["foOBarr", "Baz"]
        let assertionFour = ["FOOBarBaz"]
        
        let mockOne = "Foo Bar Baz"
        let mockTwo = "foo, Bar, baz"
        let mockThree = "foO1. Barr, Baz-2"
        let mockFour = "FOOBar  Baz"
        
        let mockViewModel = WeatherViewModelMock(callback: mockCallback)

        XCTAssertEqual(mockViewModel.filterCities(mockOne), assertionOne)
        XCTAssertEqual(mockViewModel.filterCities(mockTwo), assertionTwo)
        XCTAssertEqual(mockViewModel.filterCities(mockThree), assertionThree)
        XCTAssertEqual(mockViewModel.filterCities(mockFour), assertionFour)
    }
}
```
## RxSwift

Second branch created to try RxSwift. 


Succeeded to implement logic from main branch.

## Authors

 Paul Matar
 [@p_a_matar](https://twitter.com/p_a_matar)



## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments


[Open Weather API](https://openweathermap.org)
