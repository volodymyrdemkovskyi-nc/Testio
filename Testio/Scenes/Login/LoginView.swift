//
//  LoginView.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 25/06/2025.
//

import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            backgroundView

            if viewModel.authenticationStatus == .loading {
                loadListView
            } else {
                loginFormView
            }
        }
        .ignoresSafeArea()
        .alert(isPresented: Binding(
            get: { viewModel.alertInfo != nil },
            set: { _ in viewModel.alertInfo = nil }
        )) {
            if let alertInfo = viewModel.alertInfo {
                if alertInfo.type == .withActions {
                    return Alert(
                        title: Text(alertInfo.title),
                        message: Text(alertInfo.message),
                        primaryButton: .default(Text(AppConfigurator.Strings.yes)) {
                            Task {
                                viewModel.authenticationTrigger.send(.saveBiometricData)
                            }
                        },
                        secondaryButton: .cancel(Text(AppConfigurator.Strings.no)) {
                            Task {
                                viewModel.authenticationTrigger.send(.saveToken)
                            }
                        }
                    )
                } else {
                    return Alert(
                        title: Text(alertInfo.title),
                        message: Text(alertInfo.message),
                        dismissButton: .default(Text(AppConfigurator.Strings.ok))
                    )
                }
            }
            return Alert(
                title: Text(AppConfigurator.Strings.errorTitle),
                message: Text(AppConfigurator.Strings.anUnexpectedErrorOccurred),
                dismissButton: .default(Text(AppConfigurator.Strings.ok))
            )
        }
        .task {
            viewModel.authenticationTrigger.send(.checkAuthenticationType)
        }
    }
}

// MARK: - View Components
fileprivate extension LoginView {
    var backgroundView: some View {
        VStack {
            Spacer()
            AppConfigurator.Images.background.image?
                .resizable()
                .scaledToFit()
        }
    }

    var loadListView: some View {
        ProgressView(AppConfigurator.Strings.loading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundView)
    }

    var loginFormView: some View {
        VStack(spacing: AppConfigurator.Sizes.loginSpacing) {
            Spacer()
            AnimatedLogo()

            LoginFormView(viewModel: viewModel)
            Spacer()
        }
        .padding(AppConfigurator.Sizes.padding_32)
        .adjustForKeyboard()
    }
}

// MARK: - Preview
#Preview {
    LoginView(viewModel: LoginViewModel())
}
