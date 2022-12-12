import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
