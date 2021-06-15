import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_call_load_twice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_outputsConnectivityErrorWhenHTTPClientFails() {
        let (sut, client) = makeSUT()
        
        var completionError: RemoteFeedLoader.Error?
        sut.load { error in completionError = error}
        
        let error = NSError(domain: "", code: 0, userInfo: nil)
        client.complete(with: error)
        
        XCTAssertEqual(completionError, .connectivityError)
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions: ((Error) -> ())?
        
        var error: RemoteFeedLoader.Error?

        func get(from url: URL, completion: @escaping (Error) -> ()) {
            requestedURLs.append(url)
            completions = completion
        }
        
        func complete(with error: Error) {
            completions?(error)
        }
    }

}
