
import Foundation
import EssentialFeed

func uniqueFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueFeedImage(), uniqueFeedImage()]
    let localFeedImage = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    
    return (feed, localFeedImage)
}

func uniqueFeedImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Double) -> Date {
        self + seconds
    }
}

