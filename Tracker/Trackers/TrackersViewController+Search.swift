import Foundation
import UIKit

// MARK: - Search Handling
extension TrackersViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(), !query.isEmpty else {
            Task {
                await viewModel.clearSearch()
                collectionView.reloadData()
                updatePlaceholder(isSearching: false)
            }
            return
        }
        
        Task {
            await viewModel.filterTrackers(with: query)
            collectionView.reloadData()
            updatePlaceholder(isSearching: true)
        }
    }
    
    // MARK: - Update Placeholder
    private func updatePlaceholder(isSearching: Bool) {
        let isEmptySearchResults = isSearching && viewModel.filteredCategories.isEmpty
        
        placeholderImage.isHidden = !isEmptySearchResults
        labelImage.isHidden = !isEmptySearchResults
        
        if isEmptySearchResults {
            labelImage.text = NSLocalizedString("nothingFound", comment: "Ничего не найдено")
            placeholderImage.image = UIImage(named: "error_image")
        } else {
            labelImage.text = NSLocalizedString("emptyTrackers", comment: "Что будем отслеживать?")
            placeholderImage.image = UIImage(named: "placeholder_image")
        }
    }
}
