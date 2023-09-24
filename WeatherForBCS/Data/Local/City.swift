//
//  City.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

struct City: Codable {
    let city: CityInfo
    var weather: WeatherResponse?
}
