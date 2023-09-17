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
    func getCity(city: String, success: @escaping (CityInfo) -> Void, failure: @escaping () -> Void)
}

class WeatherProvider: WeatherService {
    func getCity(city: String, success: @escaping (CityInfo) -> Void, failure: @escaping () -> Void) {
        let url = "https://geocoding-api.open-meteo.com/v1/search"
        let parameters: [String: Any] = ["name": city, "language": "ru"]
        AF.request(url, parameters: parameters).responseJSON { response in
            let decoder = JSONDecoder()
            if let data = response.data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let result = results.first,
                       let name = result["name"] as? String,
                       let latitude = result["latitude"] as? Double,
                       let longitude = result["longitude"] as? Double {
                           let cityInfo = CityInfo(name: name, latitude: latitude, longitude: longitude)
                           success(cityInfo)
                    }
                } catch {
                    print("Ошибка при декодировании: \(error)")
                    failure()
                }

            }
        }
    }
}

class WeatherInteractor {
    private let service: WeatherService = WeatherProvider()
    
    func getCity(city: String, success: @escaping (CityInfo) -> Void, failure: @escaping () -> Void) {
        service.getCity(city: city, success:  success, failure: failure)
    }
}

struct CityInfo: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}
