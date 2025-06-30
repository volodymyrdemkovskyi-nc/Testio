//
//  AppManager.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 25/06/2025.
//

import Foundation
import Combine

protocol AuthenticationSessionProtocol {
    var authenticationStatusSubject: PassthroughSubject<Bool, Never> { get }
    var accessToken: String? { get set }
    func checkSessionValidity() -> Bool
    func clearSessionToken()
    func storeSessionToken(newToken: String)
}

class AuthenticationSessionHandler: AuthenticationSessionProtocol {
    static let shared = AuthenticationSessionHandler(keychainManager: KeychainManager())
    let authenticationStatusSubject = PassthroughSubject<Bool, Never>()
    internal var accessToken: String? {
        didSet {
            updateAuthenticationStatus()
        }
    }
    private let keychainManager: KeychainManagerProtocol

    init(keychainManager: KeychainManagerProtocol = KeychainManager()) {
        self.keychainManager = keychainManager
    }

    func checkSessionValidity() -> Bool {
        do {
            let retrievedToken = try fetchTokenFromSecureStorage(keyIdentifier: "authSessionKey")
            if retrievedToken.isEmpty {
                accessToken = nil
                return false
            }
            accessToken = retrievedToken
            return true
        } catch {
            accessToken = nil
            return false
        }
    }

    func clearSessionToken() {
        accessToken = nil
        do {
            try eraseTokenFromStorage(keyIdentifier: "authSessionKey")
        } catch {
            print("Failed to clear token: \(error.localizedDescription)")
        }
    }

    func storeSessionToken(newToken: String) {
        accessToken = newToken
        do {
            try saveTokenToSecureStorage(authCode: newToken, keyIdentifier: "authSessionKey")
        } catch {
            print("Failed to store token: \(error.localizedDescription)")
            accessToken = nil
        }
    }

    // Private helper methods
    private func fetchTokenFromSecureStorage(keyIdentifier: String) throws -> String {
        try keychainManager.retrieveSecureData(withIdentifier: keyIdentifier)
    }

    private func eraseTokenFromStorage(keyIdentifier: String) throws {
        try keychainManager.eraseSecureData(withIdentifier: keyIdentifier)
    }

    private func saveTokenToSecureStorage(authCode: String, keyIdentifier: String) throws {
        try keychainManager.storeSecureData(dataEntry: authCode, withIdentifier: keyIdentifier)
    }

    private func updateAuthenticationStatus() {
        let isAuthenticated = accessToken != nil
        authenticationStatusSubject.send(isAuthenticated)
    }
}
