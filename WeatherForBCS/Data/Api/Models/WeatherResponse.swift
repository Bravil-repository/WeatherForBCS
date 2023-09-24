//
//  WeatherResponse.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

struct WeatherResponse: Codable {
    let time: String
    let temperature: Double
}
