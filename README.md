# Open Weather App
![180](https://user-images.githubusercontent.com/24648375/174477322-ad74dd9e-4931-48d2-aa55-c6afe416fa64.png)

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

### Concepts

* SOLID
* Object-oriented programming

### Dependencies

* No third-party dependencies were used

## In-depth 

### Model 

Codable model used to decode from JSON.

```
struct WeatherData: Codable {
    let list: [List]
    let city: City
}
```
### Generic Network Layer

Protocol Network Service with default implementation in extension.

```
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

```
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

```
code blocks for commands
```


```
code blocks for commands
```

```
code blocks for commands
```


## Authors

Contributors names and contact info

 Paul Matar
 [@p_a_matar](https://twitter.com/p_a_matar)



## License

This project is licensed under the [NAME HERE] License - see the LICENSE.md file for details

## Acknowledgments


* [Open Weather API](https://openweathermap.org)
