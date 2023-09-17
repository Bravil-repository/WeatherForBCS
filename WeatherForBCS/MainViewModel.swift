//
//  MainViewModel.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 17.09.2023.
//

import Foundation
import ReactiveKit

class MainViewModel: BindingExecutionContextProvider, DisposeBagProvider  {
    
    var bindingExecutionContext: ReactiveKit.ExecutionContext = .main
    var bag = DisposeBag()
    
    let interactor = WeatherInteractor()
    
    init() {
        bind()
    }
    
    struct Input {
        let searchTextDidChange = Subject<String, Never>()
        let deleteCityByIndex = Subject<Int, Never>()
    }
    
    struct Output {
        let cities = Property<[String]>(["Улан-Удэ", "Новосиб", "Обнинск"])
    }
    
    let input: Input = .init()
    let output: Output = .init()
    
    func bind() {
        input.searchTextDidChange.bind(to: self) { viewModel, text in
            viewModel.interactor.getCity(
                city: text,
                success: { cityInfo in
                    print("Здесь сохраняем город в nsUserData")
                },
                failure: {
                    print("здесь будет ошибка")
                })
        }
        
        input.deleteCityByIndex.bind(to: self) { viewModel, index in
            print("Gorod Udalen")
        }
    }
}
