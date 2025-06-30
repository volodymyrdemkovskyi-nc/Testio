//
//  LoginFormView.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 27/06/2025.
//

import SwiftUI

struct LoginFormView: View {
    @ObservedObject private var loginState: LoginState
    @ObservedObject private var viewModel: LoginViewModel
    @State private var isTapped: Bool = false 

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        self.loginState = viewModel.loginState
    }

    var body: some View {
        VStack(spacing: AppConfigurator.Sizes.padding_16) {
            usernameField
            passwordField
            authSubmitButton
                .padding(.top, AppConfigurator.Sizes.padding_8)
        }
    }
}

// MARK: - View Components
fileprivate extension LoginFormView {

    var usernameField: some View {
        TestioTextField(
            inputText: $loginState.usernameInput,
            inputPlaceholder: AppConfigurator.Strings.username,
            fieldIcon: AppConfigurator.Images.username.image
        )
        .submitLabel(.done)
    }

    var passwordField: some View {
        TestioTextField(
            inputText: $loginState.passwordInput,
            inputPlaceholder: AppConfigurator.Strings.password,
            fieldIcon: AppConfigurator.Images.password.image
        )
        .submitLabel(.done)
    }

    var authSubmitButton: some View {
        TestioButton(
            buttonText: AppConfigurator.Strings.login,
            backgroundColor: AppConfigurator.Colors.primaryButtonColor,
            textColor: .white,
            isTapped: $isTapped
        )
        .disabled(viewModel.isLoading)
        .onChange(of: isTapped) {
            if isTapped {
                loginState.loginTrigger.send()
                isTapped = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let viewModel = LoginViewModel()
    LoginFormView(viewModel: viewModel)
}
