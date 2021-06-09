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

protocol HTTPClient {
    func load(from url: URL?)
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
        
        XCTAssertEqual(requestURL, client.requestedURL)
    }
    
    private func makeSUT(requestURL: URL = URL(string: "http://another.com")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: requestURL)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient{
        var requestedURL: URL? = nil
        
        func load(from url: URL? = URL(string: "http://")) {
            requestedURL = url
        }
    }
}
