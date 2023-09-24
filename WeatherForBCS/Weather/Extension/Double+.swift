//
//  Double+.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

extension Double {
    func asTemperatureString(with localeIdentifier: String? = "ru") -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = .init(identifier: "ru")
        let temp = Measurement(value: self, unit: UnitTemperature.celsius)
        return formatter.string(from: temp)
    }
}
