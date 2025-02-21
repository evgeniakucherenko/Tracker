import UIKit

final class PinnedTrackersService: PinnedTrackersServiceProtocol {
    private(set) var pinnedTrackers: [Tracker] = []
    
    func pinTracker(_ tracker: Tracker) {
        guard !pinnedTrackers.contains(where: { $0.id == tracker.id }) else { return }
        var updatedTracker = tracker
        updatedTracker.isPinned = true
        pinnedTrackers.append(updatedTracker)
    }
    
    func unpinTracker(_ tracker: Tracker) {
        pinnedTrackers.removeAll { $0.id == tracker.id }
    }
}
