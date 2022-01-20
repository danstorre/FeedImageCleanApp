
import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "a domain error", code: 1, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}
