//
//  UserService.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 25/06/2025.
//

import Foundation
import Combine

protocol UserAuthServiceProtocol {
    func obtainAuthToken(forUser: UserCredentials) async throws -> Authorization
}

class UserAuthService: UserAuthServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    func obtainAuthToken(forUser: UserCredentials) async throws -> Authorization {
        guard let accessPoint = AppConfigurator.URLs.Tokens else {
            throw NetworkManager.NetworkError.invalidEndpoint
        }

        do {
            let authResponse = try await networkManager.executePostRequest(atEndpoint: accessPoint, withPayload: forUser, expecting: Authorization.self, headers: nil)
            return validateAndReturnToken(responseData: authResponse)
        } catch {
            throw processAuthError(occurredError: error)
        }
    }

    // MARK: - Private Helper Methods
    private func validateAndReturnToken(responseData: Authorization) -> Authorization {
        return responseData
    }

    private func processAuthError(occurredError: Error) -> Error {
        print("Authentication error: \(occurredError.localizedDescription)")
        return occurredError
    }
}
