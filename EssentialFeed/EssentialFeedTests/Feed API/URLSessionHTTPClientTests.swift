import XCTest
import EssentialFeed

class HTTPSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class HTTPSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_deliversErrorOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        URLProtocol.registerClass(URLProtocolStub.self)
        let url = URL(string: "http://a-url.com")!
        let requestError = NSError(domain: "a domain error", code: 1)
        
        URLProtocolStub.stub(url: url, error: requestError)
        
        let sut = HTTPSessionHTTPClient()
        
        let expec = XCTestExpectation(description: "wait for service to finish.")
        
        sut.get(from: url, completion: { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, requestError.domain)
                XCTAssertEqual(receivedError.code, requestError.code)
            default:
                XCTFail("expected \(requestError), but got result \(result) instead")
            }
            
            expec.fulfill()
        })
        
        wait(for: [expec], timeout: 1)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: - Helpers
    
    class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
