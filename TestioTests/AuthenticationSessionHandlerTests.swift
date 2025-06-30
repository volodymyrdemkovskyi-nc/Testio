//
//  AuthenticationSessionHandlerTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 29/06/2025.
//

import XCTest
import Combine
@testable import Testio

class MockKeychainManager: KeychainManagerProtocol {
    var storedData: [String: String] = [:]
    var errorToThrow: KeychainManager.StorageError?

    func storeSecureData(dataEntry: String, withIdentifier: String) throws {
        if let error = errorToThrow { throw error }
        storedData[withIdentifier] = dataEntry
    }

    func retrieveSecureData(withIdentifier: String) throws -> String {
        if let error = errorToThrow { throw error }
        if let value = storedData[withIdentifier] {
            return value
        } else {
            throw KeychainManager.StorageError.dataNotFound
        }
    }

    func eraseSecureData(withIdentifier: String) throws {
        if let error = errorToThrow { throw error }
        storedData.removeValue(forKey: withIdentifier)
    }
}

class AuthenticationSessionHandlerTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var authHandler: AuthenticationSessionHandler!
    var mockKeychain: MockKeychainManager!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockKeychain = MockKeychainManager()
        authHandler = AuthenticationSessionHandler(keychainManager: mockKeychain)
    }

    override func tearDown() {
        cancellables.removeAll()
        authHandler.clearSessionToken()
        super.tearDown()
    }

    func testTokenStorage() {
        authHandler.storeSessionToken(newToken: "testToken")
        XCTAssertEqual(mockKeychain.storedData["authSessionKey"], "testToken")
        XCTAssertEqual(authHandler.accessToken, "testToken")
    }

    func testClearSessionToken() {
        authHandler.storeSessionToken(newToken: "testToken")
        authHandler.clearSessionToken()
        XCTAssertNil(mockKeychain.storedData["authSessionKey"])
        XCTAssertNil(authHandler.accessToken)
    }

    func testSessionValidityWithToken() {
        mockKeychain.storedData["authSessionKey"] = "validToken"
        let isValid = authHandler.checkSessionValidity()
        XCTAssertTrue(isValid)
        XCTAssertEqual(authHandler.accessToken, "validToken")
    }

    func testSessionValidityWithoutToken() {
        let isValid = authHandler.checkSessionValidity()
        XCTAssertFalse(isValid)
        XCTAssertNil(authHandler.accessToken)
    }
}
