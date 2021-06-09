import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.load(from: url)
    }
}

class HTTPClient {
    var requestedURL: URL? = nil
    
    func load(from url: URL? = URL(string: "http://")) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesntMakeAnyRequests() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_doesMakeTheRequestNeed() {
        let requestURL = URL(string: "http://another.com")!
        let (sut, client) = makeSUT(requestURL: requestURL)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(requestURL, client.requestedURL)
    }
    
    func makeSUT(requestURL: URL = URL(string: "http://another.com")!) -> (RemoteFeedLoader, HTTPClient){
        let client = HTTPClient()
        let sut = RemoteFeedLoader(client: client, url: requestURL)
        
        return (sut, client)
    }
}
