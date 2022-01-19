
import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.cache(feed: feed, completion: completion)
            }
        }
    }
    
    public func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        })
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] feedStoreResult in
            switch feedStoreResult {
            case let .found(local: items, timestamp: timestamp) where self.validate(timestamp):
                completion(.success(items.toModel()))
            case let .failure(error: error):
                self.store.deleteCachedFeed(completion: { _ in })
                completion(.failure(error))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    
    static let maxDaysInCache = -7
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxAge = calendar.date(byAdding: .day, value: Self.maxDaysInCache, to: currentDate()) else {
            return false
        }
        
        return timestamp > maxAge
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
