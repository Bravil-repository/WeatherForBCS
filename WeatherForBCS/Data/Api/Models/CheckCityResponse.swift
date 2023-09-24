//
//  CheckCityResponse.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 24.09.2023.
//

import Foundation

struct CheckCityResponse: Codable {
    let results: [CityInfo]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decodeIfPresent([CityInfo].self, forKey: .results)
    }
}
