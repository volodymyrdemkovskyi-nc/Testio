//
//  KeychainManager.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import Foundation
import Security

protocol KeychainManagerProtocol {
    func storeSecureData(dataEntry: String, withIdentifier: KeychainManager.KeychainKey) throws
    func retrieveSecureData(withIdentifier: KeychainManager.KeychainKey) throws -> String
    func eraseSecureData(withIdentifier: KeychainManager.KeychainKey) throws
}

class KeychainManager: KeychainManagerProtocol {
    static let storageIdentifier = Bundle.main.bundleIdentifier ?? "com.testio.app"

    enum StorageError: Error, Equatable {
        case dataNotFound
        case duplicateEntry
        case invalidDataStructure
        case unexpectedOperationResult(OSStatus)

        var localizedDescription: String {
            switch self {
            case .dataNotFound:
                return "Requested data was not found in secure storage."
            case .duplicateEntry:
                return "Duplicate entry detected in secure storage."
            case .invalidDataStructure:
                return "Data structure in secure storage is invalid."
            case .unexpectedOperationResult(let status):
                return "Unexpected operation result with status code: \(status)"
            }
        }
    }

    enum KeychainKey: String {
        case username
        case password
        case token
    }

    func storeSecureData(dataEntry: String, withIdentifier: KeychainKey) throws {
        let encodedData = encodeTextToData(inputText: dataEntry)
        let storageQuery = buildStorageQuery(uniqueKey: withIdentifier.rawValue, dataContent: encodedData)
        try executeStorageOperation(query: storageQuery)
    }

    func retrieveSecureData(withIdentifier: KeychainKey) throws -> String {
        let retrievalQuery = buildRetrievalQuery(uniqueKey: withIdentifier.rawValue)
        let retrievedData = try performDataRetrieval(query: retrievalQuery)
        return decodeDataToText(retrievedData: retrievedData)
    }

    func eraseSecureData(withIdentifier: KeychainKey) throws {
        let deletionQuery = buildDeletionQuery(uniqueKey: withIdentifier.rawValue)
        try performDataDeletion(query: deletionQuery)
    }

    // MARK: - Private Helper Methods
    private func encodeTextToData(inputText: String) -> Data {
        return inputText.data(using: .utf8) ?? Data()
    }

    private func buildStorageQuery(uniqueKey: String, dataContent: Data) -> [String: AnyObject] {
        return [
            kSecAttrService as String: (KeychainManager.storageIdentifier as String?) as AnyObject,
            kSecAttrAccount as String: uniqueKey as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: dataContent as AnyObject
        ]
    }

    private func executeStorageOperation(query: [String: AnyObject]) throws {
        let operationResult = SecItemAdd(query as CFDictionary, nil)
        if operationResult == errSecDuplicateItem {
            throw StorageError.duplicateEntry
        }
        guard operationResult == errSecSuccess else {
            throw StorageError.unexpectedOperationResult(operationResult)
        }
    }

    private func buildRetrievalQuery(uniqueKey: String) -> [String: AnyObject] {
        return [
            kSecAttrService as String: (KeychainManager.storageIdentifier as String?) as AnyObject,
            kSecAttrAccount as String: uniqueKey as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
    }

    private func performDataRetrieval(query: [String: AnyObject]) throws -> Data {
        var itemCopy: AnyObject?
        let operationResult = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        guard operationResult != errSecItemNotFound else {
            throw StorageError.dataNotFound
        }
        guard operationResult == errSecSuccess else {
            throw StorageError.unexpectedOperationResult(operationResult)
        }
        guard let data = itemCopy as? Data else {
            throw StorageError.invalidDataStructure
        }
        return data
    }

    private func decodeDataToText(retrievedData: Data) -> String {
        return String(decoding: retrievedData, as: UTF8.self)
    }

    private func buildDeletionQuery(uniqueKey: String) -> [String: AnyObject] {
        return [
            kSecAttrService as String: (KeychainManager.storageIdentifier as String?) as AnyObject,
            kSecAttrAccount as String: uniqueKey as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
    }

    private func performDataDeletion(query: [String: AnyObject]) throws {
        let operationResult = SecItemDelete(query as CFDictionary)
        guard operationResult == errSecSuccess || operationResult == errSecItemNotFound else {
            throw StorageError.unexpectedOperationResult(operationResult)
        }
    }
}
