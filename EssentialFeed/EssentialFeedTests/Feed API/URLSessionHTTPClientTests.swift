import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class HTTPSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let task = HTTPSessionTaskSpy()
        let session = HTTPSessionSpy()
        session.stub(url: url, task: task)
        let sut = HTTPSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_deliversErrorOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let error = NSError(domain: "a domain error", code: 1)
        let session = HTTPSessionSpy()
        session.stub(url: url, error: error)
        let sut = HTTPSessionHTTPClient(session: session)
        
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
    
    class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeHTTPSessionTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("couldn't find any stub from \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    class FakeHTTPSessionTask: HTTPSessionTask {
        func resume() {}
    }
    
    class HTTPSessionTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
