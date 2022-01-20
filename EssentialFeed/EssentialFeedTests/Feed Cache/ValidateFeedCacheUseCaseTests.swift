
import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        sut.validateCache()
        
        store.completeRetrieve(with: retrievalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let lessThanSevenDaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        store.completeWith(items: uniqueFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesOnSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let sevenDaysOldTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        store.completeWith(items: uniqueFeed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesOnMoreThanSevenDaysOldCache() {
        let currentDate = Date()
        let uniqueFeed = uniqueFeed()
        let moreThanSevenDaysOldCache = currentDate.adding(days: -7).adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        store.completeWith(items: uniqueFeed.local, timestamp: moreThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    // MARK:- Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(instance: store, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        return (sut, store)
    }
}
