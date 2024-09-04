//
//  IrregularEventController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 04.09.2024.
//

import Foundation
import UIKit

final class IrregularEventController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar() 
    }
    
    
    private func setupNavBar() {
        _ = TitlePopup(title: "Новое нерегулярное событие", navigationItem: navigationItem)
    }
}
