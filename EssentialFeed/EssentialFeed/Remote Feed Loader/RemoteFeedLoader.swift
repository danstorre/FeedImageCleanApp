import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> ())
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping ((Error) -> Void) = { _ in }) {
        client.get(from: url) { error, response  in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivityError)
            }
        }
    }
}
