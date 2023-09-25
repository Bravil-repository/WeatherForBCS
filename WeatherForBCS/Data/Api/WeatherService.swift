//
//  WeatherService.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 17.09.2023.
//

import Foundation
import Alamofire
import ReactiveKit

protocol WeatherService {
    func getCity(by name: String) -> Signal<CityInfo?, NSError>
    func checkTemperature(for cityResponse: CityInfo) -> Signal<CheckWeatherResponse, NSError>
}

class WeatherProvider: WeatherService {
    func getCity(by name: String) -> Signal<CityInfo?, NSError> {
        let url = "https://geocoding-api.open-meteo.com/v1/search"
        let parameters: [String: Any] = ["name": name, "language": "ru"]
        
        return Signal<CityInfo?, NSError> { observer in
            AF.request(url, parameters: parameters).responseDecodable(of: CheckCityResponse.self) { response in
                switch response.result {
                case let .success(citiesResponse):
                    if let cityInfo = citiesResponse.results?.first {
                        observer.receive(cityInfo)
                    } else {
                        observer.receive(nil)
                    }
                case let .failure(error):
                    observer.receive(completion: .failure(error as NSError))
                }
            }
            
            return BlockDisposable {}
        }
    }
    
    func checkTemperature(for cityResponse: CityInfo) -> Signal<CheckWeatherResponse, NSError> {
        let url = "https://api.open-meteo.com/v1/forecast"
        let parameters: [String: Any] = [
            "latitude": cityResponse.latitude,
            "longitude": cityResponse.longitude,
            "current_weather": true
        ]
        
        return Signal<CheckWeatherResponse, NSError> { observer in
            AF.request(url, parameters: parameters).responseDecodable(of: CheckWeatherResponse.self) { response in
                switch response.result {
                case let .success(checkWeatherResponse):
                    observer.receive(checkWeatherResponse)
                case let .failure(error):
                    observer.receive(completion: .failure(error as NSError))
                }
            }
            
            return BlockDisposable {}
        }
    }
}
