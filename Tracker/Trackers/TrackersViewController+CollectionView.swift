import UIKit

extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCell
        
        let tracker = viewModel.filteredCategories[indexPath.section].trackers[indexPath.row]
        
        cell.onCompletionToggle = { [weak self] in
            Task {
                await self?.viewModel.toggleTrackerCompletion(tracker)
                DispatchQueue.main.async {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        Task {
            let completionCount = await viewModel.getCompletionCount(for: tracker)
            let isCompleted = viewModel.isTrackerCompleted(tracker)
            
            await MainActor.run {
                cell.configure(
                    with: tracker.name,
                    days: completionCount,
                    category: viewModel.filteredCategories[indexPath.section].title,
                    emoji: tracker.emoji,
                    color: tracker.color,
                    isRepeatedCategory: indexPath.item > 0,
                    isCompleted: isCompleted,
                    isPinned: tracker.isPinned
                )
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 9
        let sideInset: CGFloat = 16
        let totalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenCells + 2 * sideInset
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        print("Context menu requested for indexPath: \(indexPath)")
        
        guard let tracker = viewModel.getTracker(at: indexPath) else {
            print("Tracker not found for indexPath: \(indexPath)")
            return nil
        }
        
        let isPinned = viewModel.titleForSection(indexPath.section) == NSLocalizedString("pinned", comment: "")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            
            let pinAction = UIAction(
                title: isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: "")
            ) { _ in
                if isPinned {
                    self.viewModel.unpinTracker(tracker)
                } else {
                    self.viewModel.pinTracker(tracker)
                }
            }
            
            let editAction = UIAction(
                title: NSLocalizedString("edit", comment: "")
            ) { _ in
                self.presentEditTrackerScreen(for: tracker)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("delete", comment: "Удалить"),
                attributes: .destructive
            ) { _ in
                self.alertPresenter.presentConfirmationAlert(
                    message: NSLocalizedString("confirmDeleteTracker", comment: ""),
                    destructiveTitle: NSLocalizedString("delete", comment: ""),
                    destructiveHandler: {
                        Task {
                            await self.viewModel.deleteTracker(tracker)
                            await MainActor.run {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                )
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
