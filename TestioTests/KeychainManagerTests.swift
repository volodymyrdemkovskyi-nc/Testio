//
//  KeychainManagerTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 29/06/2025.
//

import XCTest
@testable import Testio

class KeychainManagerTests: XCTestCase {
    var keychainManager: KeychainManager!

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
    }

    override func tearDown() {
        do {
            try keychainManager.eraseSecureData(withIdentifier: "testKey")
        } catch {
            print("Cleanup failed: \(error)")
        }
        super.tearDown()
    }

    func testStoreRetrieveErase() {
        XCTAssertNoThrow(try keychainManager.storeSecureData(dataEntry: "test", withIdentifier: "testKey"))
        XCTAssertEqual(try keychainManager.retrieveSecureData(withIdentifier: "testKey"), "test")
        XCTAssertNoThrow(try keychainManager.eraseSecureData(withIdentifier: "testKey"))
        XCTAssertThrowsError(try keychainManager.retrieveSecureData(withIdentifier: "testKey")) { error in
            XCTAssertEqual(error as? KeychainManager.StorageError, .dataNotFound)
        }
    }

    func testStoreDuplicateEntry() {
        XCTAssertNoThrow(try keychainManager.storeSecureData(dataEntry: "test", withIdentifier: "testKey"))
        XCTAssertThrowsError(try keychainManager.storeSecureData(dataEntry: "test2", withIdentifier: "testKey")) { error in
            XCTAssertEqual(error as? KeychainManager.StorageError, .duplicateEntry)
        }
    }
}
