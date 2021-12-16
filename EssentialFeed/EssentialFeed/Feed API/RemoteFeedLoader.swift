import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Result) -> Void)) {
        client.get(from: url) { [weak self] response in
            guard self != nil else { return }
            
            switch response {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let remoteItems = try FeedItemsMapper.map(data, response: response)
            return .success(remoteItems.toFeedItems())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toFeedItems() -> [FeedImage] {
        map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
