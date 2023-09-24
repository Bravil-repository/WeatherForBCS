//
//  CheckWeatherResponse.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

struct CheckWeatherResponse: Codable {
    let currentWeather: WeatherResponse
    
    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
}
