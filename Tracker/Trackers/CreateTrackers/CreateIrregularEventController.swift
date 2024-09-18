//
//  IrregularEventController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 04.09.2024.
//

import Foundation
import UIKit


final class IrregularEventController: UIViewController {
    
    // MARK: - Properties
    weak var irregularEventDelegate: IrregularEventControllerDelegate?
    
    private var trackerRecords: [TrackerRecord] = []
    private var selectedCategory: String?
    private var categoryButtonTopConstraint: NSLayoutConstraint?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojiCollectionView = EmojiCollectionView()
    private let colorsCollectionView = ColorsCollectionView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var categoryStore: TrackerCategoryStoreProtocol

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupScrollView()
        setupConstraints()
        nameTextField.delegate = self
        
        setupCollectionViewCallbacks() 
        updateCreateButtonState()
    }
    
    // MARK: - UI Elements
    private lazy var cancelButton: UIButton = {
        let button = createButton(title: "Отменить", backgroundColor: .clear)
        button.setTitleColor(UIColor(named: "red_YP"), for: .normal)
        button.layer.borderColor = UIColor(named: "red_YP")?.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = createButton(title: "Создать", backgroundColor: .grayColorYP)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Введите название трекера"
        textField.autocapitalizationType = .words
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .redYP
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoryButton: CustomSelectionButton = {
        let button = CustomSelectionButton(title: "Категория")
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Setup Methods
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = backgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupNavBar() {
        _ = TitlePopup(title: "Новое нерегулярное событие", navigationItem: navigationItem)
    }

    private func setupViews() {
        [cancelButton,createButton,nameTextField,errorLabel,
         categoryButton, emojiCollectionView, colorsCollectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupCollectionViewCallbacks() {
        emojiCollectionView.onEmojiSelected = { [weak self] emoji in
            self?.selectedEmoji = emoji
            self?.updateCreateButtonState()
        }
        
        colorsCollectionView.onColorSelected = { [weak self] color in
            self?.selectedColor = color
            self?.updateCreateButtonState()
        }
    }

    // MARK: - Actions
    private func updateCreateButtonState() {
        let isNameFilled = !(nameTextField.text?.isEmpty ?? true)
        let isCategorySelected = selectedCategory != nil
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        if isNameFilled && isCategorySelected && isEmojiSelected && isColorSelected {
            createButton.backgroundColor = .blackYP
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .grayColorYP
            createButton.isEnabled = false
        }
    }

    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text, !trackerName.isEmpty else {
            return
        }
        
        guard let selectedEmoji = selectedEmoji, let selectedColor = selectedColor else { return }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: []
        )

        let currentDate = Date()
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)

        saveTrackerRecord(trackerRecord)

        irregularEventDelegate?.didCreateIrregularEvent(tracker, inCategory: selectedCategory ?? "Без категории")
        closeModalAndSwitchToTab(index: 0)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func cancelButtonTapped() {
        closeModalAndSwitchToTab(index: 0)
    }

    @objc private func categoryButtonTapped() {
        let categoryViewController = CategoryViewController(categoryStore: categoryStore)
        categoryViewController.delegate = self
        let navController = UINavigationController(rootViewController: categoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func closeModalAndSwitchToTab(index: Int) {
        guard let window = UIApplication.shared.windows.first else { return }

        if let tabBarController = window.rootViewController as? TabBarController {
            tabBarController.selectedIndex = index
        }

        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func saveTrackerRecord(_ record: TrackerRecord) {
        trackerRecords.append(record)
    }
}

// MARK: - CategoryViewControllerDelegate & UITextFieldDelegate
extension IrregularEventController: CategorySelectionDelegate & UITextFieldDelegate {
    func didSelectCategory(_ categoryName: String) {
        selectedCategory = categoryName
        categoryButton.update(title: "Категория", subtitle: categoryName)
        updateCreateButtonState()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if !updatedText.isEmpty {
            let firstLetter = updatedText.prefix(1).capitalized
            let remainingText = updatedText.dropFirst()
            updatedText = firstLetter + remainingText.lowercased()
        }
        
        if updatedText.count > 38 {
            errorLabel.isHidden = false
            categoryButtonTopConstraint?.constant = 24
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            return false
        } else {
            errorLabel.isHidden = true
            categoryButtonTopConstraint?.constant = 8
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            textField.text = updatedText
            updateCreateButtonState()
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        errorLabel.isHidden = true
        categoryButtonTopConstraint?.constant = 8
            
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
            
        updateCreateButtonState()
        return true
    }
}

extension IrregularEventController{
    // MARK: - Layout
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupConstraints() {

        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)
        
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),

            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryButtonTopConstraint!,
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            emojiCollectionView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 250),

            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}
