import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Result) -> Void)) {
        client.get(from: url) { [weak self] response in
            guard self != nil else { return }
            
            switch response {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, response: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
