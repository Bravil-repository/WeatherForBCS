//
//  MainViewController.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 17.09.2023.
//

import UIKit
import SnapKit
import ReactiveKit

class MainViewController: UIViewController, BindingExecutionContextProvider {
    var bindingExecutionContext: ReactiveKit.ExecutionContext = .main

    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private let viewModel = MainViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.right.left.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchBar.delegate = self
        searchBar.placeholder = "Поиск города"
        
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CitiesCell.self, forCellReuseIdentifier: "citiesCell")
    }
    
    func bind() {
        viewModel.output.cities.bind(to: self) { vc, cities in
            vc.tableView.reloadData()
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    // Отправка во вью модель текста
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            viewModel.input.searchTextDidChange.next(text)
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView( _ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            print("delete")
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        return swipeAction
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.cities.value.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell") as? CitiesCell else {
            return UITableViewCell()
        }
        let city = viewModel.output.cities.value[indexPath.row]
        let temperature = "15 °C"
        cell.update(city: city, temperature: temperature)
        return cell
    }
}


class CitiesCell: UITableViewCell {
    
    let cityName = UILabel()
    let temperature = UILabel()
    static let identifier = "citiesCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "citiesCell")
        setupUI()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {

        contentView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        contentView.addSubview(cityName)
        cityName.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        cityName.font = .boldSystemFont(ofSize: 20)
        
        
        contentView.addSubview(temperature)
        temperature.snp.makeConstraints { make in
            make.left.equalTo(cityName.snp.right).offset(50)
            make.right.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        temperature.font = .boldSystemFont(ofSize: 30)
    }
    
    func update(city: String, temperature: String) {
        self.cityName.text = city
        self.temperature.text = temperature
    }
}
