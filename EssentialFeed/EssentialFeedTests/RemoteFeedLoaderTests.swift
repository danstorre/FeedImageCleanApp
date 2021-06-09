import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    let requestedURL: URL? = nil
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesntMakeAnyRequests() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
