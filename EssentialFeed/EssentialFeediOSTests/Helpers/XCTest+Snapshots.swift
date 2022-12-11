//
//  XCTest+Snapshots.swift
//  EssentialFeediOSTests
//
//  Created by Daniel Torres on 11/28/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
    private func makeSnapshotURLFromTestBundle(with name: String) -> URL? {
        let testBundle = Bundle(for: FeedSnapshotTests.self)
        return testBundle.url(forResource: name, withExtension: "png")
    }

    private func storedSnapshotData(from url: URL, file: StaticString = #file, line: UInt = #line) -> Data? {
        return try? Data(contentsOf: url)
    }

    func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedImageURL = makeSnapshotURLFromTestBundle(with: name) else {
            XCTFail("Failed to load stored snapshot in test bundle with name: \(name). Use the `record` method to store a snapshot before asserting and add it to the test bundle.", file: file, line: line)
            return
        }
        
        guard let storedImageData = storedSnapshotData(from: storedImageURL) else {
            XCTFail("Failed to generate PNG data representation from snapshot at \(storedImageURL)", file: file, line: line)
            return
        }
        
        if snapshotData != storedImageData {
            let snapshotURL = makeSnapshotURL(named: name, file: file)
            
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }

    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
            
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString = #file) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }

}
