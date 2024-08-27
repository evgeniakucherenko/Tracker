//
//  NavBar.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 26.08.2024.
//

import Foundation
import UIKit

//class NavBarController:  UIViewController, UISearchResultsUpdating {
//    let searchController = UISearchController(searchResultsController: nil)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//            
//        setupNavigationBar()
//        setupSearchController()
//    }
//    
//    private func setupNavigationBar() {
//        navigationItem.title = "Трекеры"
//        navigationController?.navigationBar.prefersLargeTitles = true
//  
//        let dateLabel = UILabel()
//        dateLabel.text = "14.12.22"
//        dateLabel.font = UIFont.systemFont(ofSize: 17)
//        dateLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
//        dateLabel.layer.cornerRadius = 8
//        dateLabel.layer.masksToBounds = true
//        dateLabel.textAlignment = .center
//        dateLabel.widthAnchor.constraint(equalToConstant: 77).isActive = true
//        dateLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
//
//        let rightItem = UIBarButtonItem(customView: dateLabel)
//        navigationItem.rightBarButtonItem = rightItem
//        
//        // Ожидаем, пока навигационный бар загрузится
//            DispatchQueue.main.async {
//                if let navigationBar = self.navigationController?.navigationBar {
//                    // Добавляем кнопку в навигационный бар
//                    navigationBar.addSubview(self.addButton)
//                    
//                    // Настраиваем констрейнты для кнопки
//                    NSLayoutConstraint.activate([
//                        self.addButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 6),
//                        self.addButton.topAnchor.constraint(equalTo: navigationBar.topAnchor),
//                        self.addButton.widthAnchor.constraint(equalToConstant: 42),
//                        self.addButton.heightAnchor.constraint(equalToConstant: 42)
//                    ])
//                }
//            }
//    }
//    
//    private func setupSearchController() {
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false // Отключает затемнение фона
//        searchController.hidesNavigationBarDuringPresentation = false  // Оставляет заголовок на месте
//        
//        searchController.searchBar.placeholder = "Поиск"
//        navigationItem.searchController = searchController
//        
//        navigationItem.hidesSearchBarWhenScrolling = false // Оставляет строку поиска всегда видимой
//        definesPresentationContext = true
//    }
//    
//    private lazy var addButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(.addIcon, for: .normal)
//        button.tintColor = .blackYP
//        button.addTarget(self,  action: #selector(AddButtonTapped), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//      @objc private func AddButtonTapped() {
//          print("Add button tapped")
//      }
//    
//    // Метод для обработки обновления результатов поиска
//     func updateSearchResults(for searchController: UISearchController) {
//         let searchText = searchController.searchBar.text ?? ""
//         print("Searching for: \(searchText)")
//     }
//}
//
//
//
//
