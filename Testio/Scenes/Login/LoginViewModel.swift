//
//  LoginViewModel.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 23/06/2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    let loginState: LoginState
    private let userAuthService: UserAuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoading = false
    @Published var alertInfo: AlertInfo?
    @Published var isAuthenticated = false

    init(loginState: LoginState = LoginState(), userAuthService: UserAuthServiceProtocol = UserAuthService()) {
        self.loginState = loginState
        self.userAuthService = userAuthService
        setupBindings()
    }

    private func setupBindings() {
        loginState.loginTrigger
            .sink { [weak self] _ in
                guard let self = self else { return }

                guard !self.loginState.usernameInput.isEmpty,
                      !self.loginState.passwordInput.isEmpty else {
                    self.isLoading = false
                    self.isAuthenticated = false
                    self.alertInfo = AlertInfo(title: AppConfigurator.Strings.verificationFailed,
                                               message: AppConfigurator.Strings.incorrectUsername)
                    return
                }

                Task {
                    await self.performLogin()
                }
            }
            .store(in: &cancellables)
    }

    private func performLogin() async {
        await MainActor.run {
            isLoading = true
            alertInfo = nil
        }

        do {
            let credentials = UserCredentials(username: loginState.usernameInput, password: loginState.passwordInput)
            let auth = try await userAuthService.obtainAuthToken(forUser: credentials)

            await MainActor.run {
                isLoading = false
                isAuthenticated = true
                alertInfo = nil
                AuthenticationSessionHandler.shared.storeSessionToken(newToken: auth.token)
            }
        } catch {
            await MainActor.run {
                isLoading = false
                self.alertInfo = AlertInfo(title: AppConfigurator.Strings.errorTitle,
                                           message: error.localizedDescription)
                isAuthenticated = false
            }
        }
    }
}
