
import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }
    
    public func cache(items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.insert(items, timestamp: currentDate(), completion: { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        })
    }
}
