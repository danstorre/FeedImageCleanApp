
import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ localFeed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve()
}
