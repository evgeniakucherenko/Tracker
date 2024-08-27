//
//  ViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 25.08.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController {


    //MARK: - UI Elements
    private let placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        return imageView
    }()

    private let labelImage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Что будем отслеживать?"
        return label
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yy"
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    //MARK: - Lifycylce
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        setupUI()
    }
}

//MARK: - Setup UI
extension TrackersViewController {

    private func setupUI() {
        setupNavBar()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        [placeholderImage,labelImage].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupNavBar() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(resource: .addIcon), for: .normal)
        addButton.tintColor = .black
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    @objc private func addButtonTapped() {
        print("Add button tapped")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            labelImage.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor)
        ])
    }
}
