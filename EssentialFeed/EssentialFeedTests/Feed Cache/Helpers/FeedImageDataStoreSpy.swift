//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
	enum Message: Equatable {
		case insert(data: Data, for: URL)
		case retrieve(dataFor: URL)
	}
	
	private(set) var receivedMessages = [Message]()
	private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionResult: Result<Void, Error>?

    func insert(_ data: Data, for url: URL) throws {
		receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
	}
	
	func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		receivedMessages.append(.retrieve(dataFor: url))
		retrievalCompletions.append(completion)
	}
	
	func completeRetrieval(with error: Error, at index: Int = 0) {
		retrievalCompletions[index](.failure(error))
	}
	
	func completeRetrieval(with data: Data?, at index: Int = 0) {
		retrievalCompletions[index](.success(data))
	}
	
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
	}
	
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
	}
}
