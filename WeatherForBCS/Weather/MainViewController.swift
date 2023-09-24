//
//  MainViewController.swift
//  WeatherForBCS
//
//  Created by Yuriy Shurygin on 17.09.2023.
//

import UIKit
import SnapKit
import ReactiveKit

class MainViewController: UITableViewController, BindingExecutionContextProvider {
    var bindingExecutionContext: ReactiveKit.ExecutionContext = .main

    private let searchBar = UISearchBar()
        
    private let viewModel = MainViewModel()
    
    let weatherCellIdentifier = "WeatherCell"

    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupNavBar()
        setupSearch()
        setupTableView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func setupNavBar() {
        title = "Погода"
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .heavy, width: .expanded)]
        UINavigationBar.appearance().largeTitleTextAttributes = attributes
    }
    
    private func setupSearch() {
        let search = UISearchBar()
        search.autocapitalizationType = .words
        search.searchBarStyle = .minimal
        search.placeholder = "Поиск города"
                
        let textFieldInsideUISearchBar = search.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = .wideBody

        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.font = .wideBody
        
        search.sizeToFit()
        search.delegate = self

        navigationItem.titleView = search
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: weatherCellIdentifier)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppear.send()
    }

    private func bind() {
        viewModel.output.cityWasRemoved.bind(to: self) { this, row in
            this.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .left)
        }
        
        viewModel.output.cityWasAdded.bind(to: self) { this, row in
            this.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        }
        
        viewModel.output.cityWasReload.bind(to: self) { this, row in
            this.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        }
        
        viewModel.output.reloadTable.bind(to: self) { this in
            this.tableView.reloadData()
        }
        
        viewModel.output.stopRefresh.delay(interval: 0.3).bind(to: self) { this in
            this.refreshControl?.endRefreshing()
        }
        
        viewModel.output.showEmptyCitiesAlert.bind(to: self) { this, searchText in
            this.showAlert(cityName: searchText)
        }
    }
    
    @objc func pullToRefresh() {
        viewModel.input.refresh.send()
    }
    
    private func showAlert(cityName: String) {
        let alert = UIAlertController(title: "Ошибка", message: "Город с именем \(cityName) не найден", preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController: UISearchBarDelegate {
    // Отправка во вью модель текста
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchBar.text = nil
            viewModel.input.checkCity.send(text)
        }
    }
}

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: weatherCellIdentifier, for: indexPath)
                
        let city = viewModel.output.cities.value[indexPath.row]
        
        let text = city.cityName
        let secondaryText = city.temperature?.asTemperatureString()
        
        var content = cell.defaultContentConfiguration()
        content.text = text
        content.textProperties.font = secondaryText == nil ? .wideLarge : .wideCaption
        content.textProperties.color = .label.withAlphaComponent(city.isLoading ? 0.3 : 1)
        
        content.secondaryText = secondaryText
        content.secondaryTextProperties.font = .wideLarge
        content.secondaryTextProperties.color = .label.withAlphaComponent(city.isLoading ? 0.3 : 1)
                
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        if city.isLoading {
            let loader = UIActivityIndicatorView(style: .medium)
            cell.contentView.addSubview(loader)
            loader.snp.makeConstraints { $0.edges.equalToSuperview() }
            loader.startAnimating()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.cities.value.count
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] action, view, handler in
            self?.viewModel.input.removeCityByIndex.send(indexPath.row)
            handler(true)
        }
        let refresh = UIContextualAction(style: .normal, title: "Обновить") { [weak self] action, view, handler in
            self?.viewModel.input.refreshCityByIndex.send(indexPath.row)
            handler(true)
        }
        let config = UISwipeActionsConfiguration(actions: [delete, refresh])
        return config
    }
}
