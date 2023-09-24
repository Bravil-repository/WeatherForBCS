//
//  WeatherInfoModel.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

struct WeatherInfoModel {
    let cityName: String
    var temperature: Double?
    var isLoading: Bool
    
    var city: City?
}
