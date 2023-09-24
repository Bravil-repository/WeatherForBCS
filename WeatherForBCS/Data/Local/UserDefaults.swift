//
//  WeatherUserDefaults.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

class WeatherUserDefaults {
    
    private let instance = UserDefaults()
    private let citiesKey = "UserDefaults-Cities"
    
    public func save(_ cities: [City]) {
        if let data = cities.toData() {
            instance.set(data, forKey: citiesKey)
        }
    }
    
    public func get() -> [City]? {
        guard let cities = instance.data(forKey: citiesKey)?.toCities()
        else { return nil }
        return cities
    }
    
}

private extension Data {
    func toCities() -> [City]? {
        let decoder = JSONDecoder()
        let cityInfo = try? decoder.decode([City].self, from: self)
        return cityInfo
    }
}

private extension [City] {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(self)
        return data
    }
}
