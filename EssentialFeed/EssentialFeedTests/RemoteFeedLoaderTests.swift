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

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_call_load_twice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_outputsConnectivityErrorWhenHTTPClientFails() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { error in capturedErrors.append(error)}
        
        let error = NSError(domain: "", code: 0, userInfo: nil)
        client.complete(with: error, at: 0)
        
        XCTAssertEqual(capturedErrors, [.connectivityError])
    }
    
    func test_load_outputsInvalidDataWhenHTTPClientsReturnsNon200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load(completion: { error in capturedErrors.append(error) })
            
            client.completeWithResponseError(with: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL,
                        completion: (HTTPClientResponse) -> ())] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> ()) {
            messages.append((url: url,
                             completion: completion))
        }
        
        func complete(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }
        
        func completeWithResponseError(with code: Int, at index: Int) {
            let httpResponse = HTTPURLResponse(url: requestedURLs[index],
                                                    statusCode: code,
                                                    httpVersion: nil,
                                                    headerFields: nil)!
            
            messages[index].completion(.success(httpResponse))

        }
    }

}
