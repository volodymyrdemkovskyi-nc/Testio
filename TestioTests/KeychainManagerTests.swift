//
//  KeychainManagerTests.swift
//  TestioTests
//
//  Created by Volodymyr Demkovskyi on 02/07/2025.
//

import XCTest
@testable import Testio

class KeychainManagerTests: XCTestCase {

    var keychainManager: KeychainManager!

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
        // Очищаємо Keychain перед кожним тестом для ізоляції
        clearKeychain()
    }

    override func tearDown() {
        // Очищаємо Keychain після кожного тесту
        clearKeychain()
        keychainManager = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func clearKeychain() {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: (KeychainManager.storageIdentifier as String?) as AnyObject
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Tests for storeSecureData

    func testStoreSecureData_SuccessfulStorage() {
        do {
            try keychainManager.storeSecureData(dataEntry: "testUser", withIdentifier: .username)
            let retrievedData = try keychainManager.retrieveSecureData(withIdentifier: .username)
            XCTAssertEqual(retrievedData, "testUser", "Stored and retrieved data should match")
        } catch {
            XCTFail("Should not throw an error: \(error.localizedDescription)")
        }
    }

    func testStoreSecureData_DuplicateEntry() {
        do {
            try keychainManager.storeSecureData(dataEntry: "testUser", withIdentifier: .username)
            XCTAssertThrowsError(try keychainManager.storeSecureData(dataEntry: "anotherUser", withIdentifier: .username)) { error in
                guard let storageError = error as? KeychainManager.StorageError else {
                    XCTFail("Should throw StorageError.duplicateEntry")
                    return
                }
                XCTAssertEqual(storageError, .duplicateEntry, "Should detect duplicate entry")
            }
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    // MARK: - Tests for retrieveSecureData

    func testRetrieveSecureData_SuccessfulRetrieval() {
        do {
            try keychainManager.storeSecureData(dataEntry: "testPass", withIdentifier: .password)
            let retrievedData = try keychainManager.retrieveSecureData(withIdentifier: .password)
            XCTAssertEqual(retrievedData, "testPass", "Retrieved data should match stored data")
        } catch {
            XCTFail("Should not throw an error: \(error.localizedDescription)")
        }
    }

    func testRetrieveSecureData_DataNotFound() {
        XCTAssertThrowsError(try keychainManager.retrieveSecureData(withIdentifier: .token)) { error in
            guard let storageError = error as? KeychainManager.StorageError else {
                XCTFail("Should throw StorageError.dataNotFound")
                return
            }
            XCTAssertEqual(storageError, .dataNotFound, "Should indicate data not found")
        }
    }

    // MARK: - Tests for eraseSecureData

    func testEraseSecureData_SuccessfulDeletion() {
        do {
            try keychainManager.storeSecureData(dataEntry: "testToken", withIdentifier: .token)
            try keychainManager.eraseSecureData(withIdentifier: .token)
            XCTAssertThrowsError(try keychainManager.retrieveSecureData(withIdentifier: .token)) { error in
                guard let storageError = error as? KeychainManager.StorageError else {
                    XCTFail("Should throw StorageError.dataNotFound after deletion")
                    return
                }
                XCTAssertEqual(storageError, .dataNotFound, "Data should be erased")
            }
        } catch {
            XCTFail("Should not throw unexpected error: \(error.localizedDescription)")
        }
    }

    func testEraseSecureData_NonExistentEntry() {
        do {
            try keychainManager.eraseSecureData(withIdentifier: .username)
            XCTAssertNoThrow(try keychainManager.eraseSecureData(withIdentifier: .username), "Should not throw error for non-existent entry")
        } catch {
            XCTFail("Should not throw error for non-existent entry: \(error.localizedDescription)")
        }
    }
}
