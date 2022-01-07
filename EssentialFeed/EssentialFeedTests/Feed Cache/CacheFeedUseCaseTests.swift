
import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let (sut, store) = makeSUT()
        
        sut.save(feed) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        sut.save(feed) { _ in }
        store.deleteWithDeletion(error: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let feed = uniqueFeed()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }
    
    func test_save_failOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.deleteWithDeletion(error: deletionError)
        })
    }
    
    func test_save_failOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceIsDeallocated() {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let timestamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { timestamp })
        let deletionError = anyNSError()
        
        var receivedErrors = [LocalFeedLoader.SaveResult] ()
        sut?.save(feed) { error in
            receivedErrors.append(error)
        }
        
        sut = nil
        store.deleteWithDeletion(error: deletionError)
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceIsDeallocated() {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let timestamp = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { timestamp })
        let insertionError = anyNSError()
        
        var receivedErrors = [LocalFeedLoader.SaveResult] ()
        sut?.save(feed) { error in
            receivedErrors.append(error)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    // MARK:- Helpers
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save([uniqueFeedImage()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let localFeedImage = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        
        return (feed, localFeedImage)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "a domain error", code: 1, userInfo: nil)
    }
    
    private func uniqueFeedImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
}
