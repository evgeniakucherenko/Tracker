import UIKit

final class NavBarConfigurator {
    
    static func configureNavigationBar(
        for viewController: UIViewController,
        title: String,
        datePicker: UIDatePicker,
        addButtonAction: Selector,
        searchResultsUpdater: UISearchResultsUpdating
    ) {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "addIcon"), for: .normal)
        addButton.tintColor = .text
        
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        addButton.addTarget(viewController, action: addButtonAction, for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: addButton)
        viewController.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.navigationItem.title = title
        viewController.navigationController?.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
        viewController.definesPresentationContext = true
    }
    
    static func configureTitle(
        for viewController: UIViewController,
        title: String
    ) {
        viewController.navigationItem.title = title
        viewController.navigationController?.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.largeTitleDisplayMode = .always
    }
}
