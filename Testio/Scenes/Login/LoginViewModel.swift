//
//  LoginView.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    
    let credentials: UserСredentials

    private let userAuthService: UserAuthServiceProtocol
    private let biometricManager: BiometricManagerProtocol
    private let keychainManager: KeychainManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentToken: String?

    @Published var alertInfo: AlertInfo?
    @Published var authenticationStatus: AuthenticationStatus = .checkAuthenticationType
    let authenticationTrigger = PassthroughSubject<AuthenticationStatus, Never>()

    enum AuthenticationStatus {
        case checkAuthenticationType
        case validateCredentials
        case loading
        case simpleAuthentication
        case biometricAuthentication
        case authorizedSimple
        case authorizedBiometric
        case saveBiometricData
        case saveToken
    }

    init(credentials: UserСredentials = UserСredentials(),
         userAuthService: UserAuthServiceProtocol = UserAuthService(),
         biometricManager: BiometricManagerProtocol = BiometricManager(),
         keychainManager: KeychainManagerProtocol = KeychainManager()) {
        self.credentials = credentials
        self.userAuthService = userAuthService
        self.biometricManager = biometricManager
        self.keychainManager = keychainManager
        setupBindings()
    }
}

// MARK: - Setup
private extension LoginViewModel {
    func setupBindings() {
        authenticationTrigger
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.authenticationStatus = status
                switch status {
                case .checkAuthenticationType:
                    Task { await self.checkAuthenticationType() }
                case .validateCredentials:
                    Task { await self.validateCredentials() }
                case .loading:
                    Task { await self.handleLoading() }
                case .simpleAuthentication:
                    Task { await self.autorize() }
                case .biometricAuthentication:
                    Task { await self.handleBiometricAuthentication() }
                case .authorizedSimple:
                    Task { await self.handleAuthorizedSimple() }
                case .authorizedBiometric:
                    Task { await self.saveToken() }
                case .saveBiometricData:
                    Task { await self.saveCredentials() }
                case .saveToken:
                    Task { await self.saveToken() }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Validation
private extension LoginViewModel {
    func validateCredentials() async {
        guard !self.credentials.username.isEmpty,
              !self.credentials.password.isEmpty else {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.verificationFailed,
                                      message: AppConfigurator.Strings.incorrectUsername,
                                      type: .simple)
            }
            return
        }

        authenticationTrigger.send(.simpleAuthentication)
    }
}

// MARK: - Authorization
private extension LoginViewModel {
    func checkAuthenticationType() async {
        do {
            let _ = try keychainManager.retrieveSecureData(withIdentifier: .username)
            let _ = try keychainManager.retrieveSecureData(withIdentifier: .password)
            let (biometricAuthentication, _) = biometricManager.checkBiometricAvailability()
            let token = AuthenticationSessionHandler.shared.accessToken
            if token == nil && biometricAuthentication != nil {
                authenticationTrigger.send(.biometricAuthentication)
            }
        } catch {
            print("No credentials in Keychain")
        }
    }

    func autorize() async {
        do {
            let auth = try await userAuthService.obtainAuthToken(forUser: credentials)
            currentToken = auth.token
            await MainActor.run {
                alertInfo = nil
                credentials.username = ""
                credentials.password = ""
            }
            let status: AuthenticationStatus = (authenticationStatus == .simpleAuthentication) ? .authorizedSimple : .authorizedBiometric
            authenticationTrigger.send(status)
        } catch {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.errorTitle,
                                      message: error.localizedDescription,
                                      type: .simple)
            }
        }
    }

    func handleBiometricAuthentication() async {
        let (biometricType, error) = biometricManager.checkBiometricAvailability()
        if biometricType == nil || error != nil {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.errorTitle,
                                      message: AppConfigurator.Strings.biometricAuthenticationUnavailable,
                                      type: .simple)
            }
            return
        }

        let (isAuthenticated, bioError) = await biometricManager.authenticateWithBiometrics()
        if !isAuthenticated || bioError != nil {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.errorTitle,
                                      message: AppConfigurator.Strings.biometricAuthenticationFailed,
                                      type: .simple)
            }
            return
        } else {
            do {
                credentials.username = try keychainManager.retrieveSecureData(withIdentifier: .username)
                credentials.password = try keychainManager.retrieveSecureData(withIdentifier: .password)

                await autorize()
            } catch {
                print("No credentials in Keychain")
            }
        }
    }
}

// MARK: - Post-Authorization
private extension LoginViewModel {
    func handleAuthorizedSimple() async {
        do {
            _ = try keychainManager.retrieveSecureData(withIdentifier: .username)
            _ = try keychainManager.retrieveSecureData(withIdentifier: .password)
        } catch {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.saveCredentialsTitle,
                                      message: AppConfigurator.Strings.saveCredentialsMessage,
                                      type: .withActions)
            }
            return
        }

        await saveToken()
    }

    func saveCredentials() async {
        do {
            try keychainManager.storeSecureData(dataEntry: credentials.username,
                                                withIdentifier: .username)
            try keychainManager.storeSecureData(dataEntry: credentials.password,
                                                withIdentifier: .password)
            authenticationTrigger.send(.saveToken)
        } catch {
            await MainActor.run {
                alertInfo = AlertInfo(title: AppConfigurator.Strings.errorTitle,
                                      message: AppConfigurator.Strings.failedToSaveCredentials,
                                      type: .simple)
            }
        }
    }

    func saveToken() async {
        await MainActor.run {
            alertInfo = nil
            if let token = currentToken {
                AuthenticationSessionHandler.shared.storeSessionToken(newToken: token)
                currentToken = nil
            }
        }
    }

    func handleLoading() async {
        await MainActor.run {
            alertInfo = nil
        }
    }
}
