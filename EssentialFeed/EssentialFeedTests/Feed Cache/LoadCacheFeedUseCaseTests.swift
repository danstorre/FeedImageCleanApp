
import XCTest
import EssentialFeed

class LoadCacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsRetrievalFromStore() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrieveError), when: {
            store.completeRetrieve(with: retrieveError)
        })
    }
    
    func test_load_deliversEmptyItemsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeWithEmptyCache()
        })
    }
    
    func test_load_deliversItemsWhenCacheOnLessThanSevenDaysOld() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let lessThanSevenDaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        expect(sut, toCompleteWith: .success(uniqueFeed.models), when: {
            store.completeWith(items: uniqueFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        })
    }
    
    func test_load_deliversEmptyItemsWhenCacheIsMoreThanSevenDaysOld() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let sevenDaysOld = currentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeWith(items: uniqueFeed.local, timestamp: sevenDaysOld)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        sut.load(completion: { _ in })
        
        store.completeRetrieve(with: retrievalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load(completion: { _ in })
        
        store.completeWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let lessThanSevenDaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load(completion: { _ in })
        
        store.completeWith(items: uniqueFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_deletesCacheOnSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let sevenDaysOldTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load(completion: { _ in })
        
        store.completeWith(items: uniqueFeed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_load_deletesCacheOnMoreThanSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let moreThanSevenDaysOldCache = currentDate.adding(days: -7).adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load(completion: { _ in })
        
        store.completeWith(items: uniqueFeed.local, timestamp: moreThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_load_doesNotReceivedAnyResultsAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedMessages = [LocalFeedLoader.LoadResult]()
        
        sut?.load(completion: { receivedMessages.append($0) })
        
        sut = nil
        store.completeWithEmptyCache()

        XCTAssertTrue(receivedMessages.isEmpty)
    }
    
    // MARK:- Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "a domain error", code: 1, userInfo: nil)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedLoadResult: LocalFeedLoader.LoadResult, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedLoadResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("expected \(expectedLoadResult), got \(receivedResult).")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func uniqueFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueFeedImage(), uniqueFeedImage()]
        let localFeedImage = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        
        return (feed, localFeedImage)
    }
    
    private func uniqueFeedImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Double) -> Date {
        self + seconds
    }
}
