//
//  Untitled.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 27/06/2025.
//

import Foundation
import Combine

protocol ServerDataServiceProtocol {
    func fetchServerList() async throws -> [Server]
}

class ServerDataService: ServerDataServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    func fetchServerList() async throws -> [Server] {
        guard let endpoint = AppConfigurator.URLs.Servers else {
            throw NetworkManager.NetworkError.invalidEndpoint
        }

        do {
            let servers = try await networkManager.executeGetRequest(atEndpoint: endpoint, expecting: [Server].self, headers: nil)
            return servers
        } catch {
            throw processFetchError(occurredError: error)
        }
    }

    // MARK: - Private Helper Methods
    private func processFetchError(occurredError: Error) -> Error {
        print("Server fetch error: \(occurredError.localizedDescription)")
        if let networkError = occurredError as? NetworkManager.NetworkError {
            switch networkError {
            case .accessDenied:
                print("Access denied, please check authentication.")
            case .malformedResponse(url: let url):
                print("Malformed response from \(url)")
            case .invalidEndpoint:
                print("Invalid endpoint provided.")
            case .unexpectedIssue:
                print("Unexpected issue occurred.")
            }
        }
        return occurredError
    }
}
