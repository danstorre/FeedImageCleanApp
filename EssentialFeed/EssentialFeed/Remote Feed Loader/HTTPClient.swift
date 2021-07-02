//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Daniel Torres on 7/2/21.
//

import Foundation

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
