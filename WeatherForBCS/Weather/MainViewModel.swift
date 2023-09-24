//
//  MainViewModel.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 17.09.2023.
//

import Foundation
import ReactiveKit

class MainViewModel: BindingExecutionContextProvider, DisposeBagProvider  {
    
    var bindingExecutionContext: ExecutionContext = .main
    var bag = DisposeBag()
    
    private var timer: Timer?
    
    struct Input {
        let checkCity = Subject<String, Never>()
        let removeCityByIndex = Subject<Int, Never>()
        let refreshCityByIndex = Subject<Int, Never>()
        
        let viewWillAppear = Subject<Void, Never>()
        let refresh = Subject<Void, Never>()
    }
    
    struct Output {
        let cities = Property<[WeatherInfoModel]>([])
        let reloadTable = Subject<Void, Never>()
        let cityWasAdded = Subject<Int, Never>()
        let cityWasRemoved = Subject<Int, Never>()
        let cityWasReload = Subject<Int, Never>()
        let stopRefresh = Subject<Void, Never>()
        let showEmptyCitiesAlert = Subject<String, Never>()
    }
    
    let input = Input()
    let output = Output()
    
    let weatherService: WeatherService = WeatherProvider()
    let weatherDefaults = WeatherUserDefaults()
    
    init() {
        bind()
    }
    
    private func bind() {
        input.checkCity.bind(to: self) { vm, cityName in
            vm.checkCity(cityName)
        }
        
        input.removeCityByIndex.bind(to: self) { vm, index in
            vm.deleteCity(index)
        }
        
        input.refreshCityByIndex.bind(to: self) { vm, index in
            vm.refreshWeather(index)
        }
        
        input.viewWillAppear.bind(to: self) { vm in
            vm.loadWeathers()
        }
        
        input.refresh.bind(to: self) { vm in
            vm.refreshWeathers()
        }
        
        output.cities.bind(to: self) { vm, cities in
            // Если город есть и нет таймера то создать и запустить таймер
            if cities.count == 0 {
                vm.timer?.invalidate()
                vm.timer = nil
            } else if vm.timer == nil{
                vm.timer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { [weak self] _ in
                    self?.refreshWeathers()
                }
            }
        }
    }
    
    private func checkCity(_ cityName: String) {
        guard !output.cities.value.contains(where: { $0.cityName == cityName }) else { return }
        weatherService.getCity(by: cityName)
            .observe(with: { [weak self] event in
                switch event {
                case let .next(cityInfo):
                    if let city = cityInfo {
                        self?.addNewCity(city)
                    } else {
                        self?.output.showEmptyCitiesAlert.send(cityName)
                    }
                case let .failed(error):
                    print(error)
                case .completed:
                    break
                }
            })
        
            .dispose(in: bag)
    }
        
    private func addNewCity(_ cityResponse: CityInfo) {
        var cities = output.cities.value
        let infoModel = WeatherInfoModel(
            cityName: cityResponse.name,
            temperature: nil,
            isLoading: true
        )
        cities.append(infoModel)
        output.cities.send(cities)
        output.cityWasAdded.send(cities.count - 1)
        checkWeather(cityResponse)
    }
    
    private func checkWeather(_ cityResponse: CityInfo) {
        weatherService.checkTemperature(for: cityResponse)
            .observe(with: { [weak self] event in
                switch event {
                case let .next(weather):
                    self?.updateWeather(cityResponse: cityResponse, weather: weather)
                    print("🏙️ Weather Response: \(weather) for \(cityResponse.name)")
                case .failed:
                    self?.updateWeatherWithFail(cityResponse)
                case .completed: break
                }
            })
            .dispose(in: bag)
    }
    
    private func updateWeather(cityResponse: CityInfo, weather: CheckWeatherResponse) {
        var cities = output.cities.value

        if var city = cities.first(where: { $0.cityName == cityResponse.name }),
           let index = cities.firstIndex(where: { $0.cityName == cityResponse.name }) {
            city.temperature = weather.currentWeather.temperature
            city.isLoading = false
            city.city = City(city: cityResponse, weather: weather.currentWeather)
            
            cities[index] = city
            output.cities.send(cities)
            output.cityWasReload.send(index)
            
            saveCities()
        }
    }
    
    private func updateWeatherWithFail(_ cityResponse: CityInfo) {
        var cities = output.cities.value

        if var city = cities.first(where: { $0.cityName == cityResponse.name }),
           let index = cities.firstIndex(where: { $0.cityName == cityResponse.name }) {
            city.temperature = nil
            city.isLoading = false
            cities[index] = city
            output.cities.send(cities)
            output.cityWasReload.send(index)
        }
    }
    
    private func deleteCity(_ index: Int) {
        var cities = output.cities.value
        cities.remove(at: index)
        output.cities.send(cities)
        output.cityWasRemoved.send(index)
        saveCities()
    }
    
    private func loadWeathers() {
        let cities = weatherDefaults.get()?.compactMap {
            WeatherInfoModel(
                cityName: $0.city.name,
                temperature: $0.weather?.temperature,
                isLoading: true,
                city: $0
            )
        } ?? []
        output.cities.send(cities)
        output.reloadTable.send()
        
        cities
            .compactMap { $0.city?.city }
            .forEach { checkWeather($0) }
    }
    
    private func refreshWeather(_ index: Int) {
        let cities = output.cities.value
        guard cities.indices.contains(where: { $0 == index }),
              let cityResponse = cities[index].city?.city
        else { return }
        checkWeather(cityResponse)
        print("🔄🏙️ refresh weather only for \(cityResponse.name)")
    }
    
    private func refreshWeathers() {
        var cities = output.cities.value
        cities.indices.forEach { index in
            var city = cities[index]
            city.isLoading = true
            cities[index] = city
        }
        output.cities.send(cities)
        output.reloadTable.send()

        cities
            .compactMap { $0.city?.city }
            .forEach { checkWeather($0) }
        
        output.stopRefresh.send()
    }
    
    private func saveCities() {
        let cities = output.cities.value.compactMap { $0.city }
        weatherDefaults.save(cities)
    }
}
