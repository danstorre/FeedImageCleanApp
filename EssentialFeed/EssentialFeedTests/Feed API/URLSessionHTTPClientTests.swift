import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
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

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_deliversErrorOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let error = NSError(domain: "a domain error", code: 1)
        let session = URLSessionSpy()
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let expec = XCTestExpectation(description: "wait for service to finish.")
        
        sut.get(from: url, completion: { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("expected \(error), but got result \(result) instead")
            }
            
            expec.fulfill()
        })
        
        wait(for: [expec], timeout: 1)
    }
    
    // MARK: - Helpers
    
    class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("couldn't find any stub from \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
