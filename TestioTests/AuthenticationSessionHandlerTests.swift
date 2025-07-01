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
    var storedData: [KeychainManager.KeychainKey: String] = [:]
    var errorToThrow: KeychainManager.StorageError?

    func storeSecureData(dataEntry: String, withIdentifier: KeychainManager.KeychainKey) throws {
        if let error = errorToThrow { throw error }
        storedData[withIdentifier] = dataEntry
    }

    func retrieveSecureData(withIdentifier: KeychainManager.KeychainKey) throws -> String {
        if let error = errorToThrow { throw error }
        if let value = storedData[withIdentifier] {
            return value
        } else {
            throw KeychainManager.StorageError.dataNotFound
        }
    }

    func eraseSecureData(withIdentifier: KeychainManager.KeychainKey) throws {
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

    // MARK: - Tests for Token Storage

    func testTokenStorage_SuccessfulStorage() {
        authHandler.storeSessionToken(newToken: "testToken")
        XCTAssertEqual(try? mockKeychain.retrieveSecureData(withIdentifier: .token), "testToken")
        XCTAssertEqual(authHandler.accessToken, "testToken")
    }

    // MARK: - Tests for Clear Session Token

    func testClearSessionToken_SuccessfulClear() {
        authHandler.storeSessionToken(newToken: "testToken")
        authHandler.clearSessionToken()
        XCTAssertNil(try? mockKeychain.retrieveSecureData(withIdentifier: .token))
        XCTAssertNil(authHandler.accessToken)
    }

    // MARK: - Tests for Session Validity

    func testSessionValidity_WithValidToken() {
        mockKeychain.storedData[.token] = "validToken"
        let isValid = authHandler.checkSessionValidity()
        XCTAssertTrue(isValid)
        XCTAssertEqual(authHandler.accessToken, "validToken")
    }

    func testSessionValidity_WithoutToken() {
        let isValid = authHandler.checkSessionValidity()
        XCTAssertFalse(isValid)
        XCTAssertNil(authHandler.accessToken)
    }

    func testSessionValidity_WithRetrievalError() {
        mockKeychain.errorToThrow = .dataNotFound
        let isValid = authHandler.checkSessionValidity()
        XCTAssertFalse(isValid)
        XCTAssertNil(authHandler.accessToken)
    }

    // MARK: - Edge Cases

    func testAccessToken_AfterMultipleStores() {
        authHandler.storeSessionToken(newToken: "token1")
        authHandler.storeSessionToken(newToken: "token2") 
        XCTAssertEqual(authHandler.accessToken, "token2")
        XCTAssertEqual(try? mockKeychain.retrieveSecureData(withIdentifier: .token), "token2")
    }
}
