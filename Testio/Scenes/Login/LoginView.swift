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
            contentView
        }
        .ignoresSafeArea()
        .alert(isPresented: alertBinding, content: alertContent)
        .task {
            viewModel.authenticationTrigger.send(.checkAuthenticationType)
        }
    }
}

// MARK: - Subviews
private extension LoginView {
    var backgroundView: some View {
        VStack {
            Spacer()
            AppConfigurator.Images.background.image?
                .resizable()
                .scaledToFit()
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.authenticationStatus {
        case .loading:
            loadingView
        default:
            loginFormView
        }
    }

    var loadingView: some View {
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

// MARK: - Alerts
private extension LoginView {
    var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertInfo != nil },
            set: { _ in viewModel.alertInfo = nil }
        )
    }

    
    func alertContent() -> Alert {
        guard let alertInfo = viewModel.alertInfo else {
            return Alert(
                title: Text(AppConfigurator.Strings.errorTitle),
                message: Text(AppConfigurator.Strings.anUnexpectedErrorOccurred),
                dismissButton: .default(Text(AppConfigurator.Strings.ok))
            )
        }

        switch alertInfo.type {
        case .withActions:
            return Alert(
                title: Text(alertInfo.title),
                message: Text(alertInfo.message),
                primaryButton: .default(Text(AppConfigurator.Strings.yes)) {
                    Task { viewModel.authenticationTrigger.send(.saveBiometricData) }
                },
                secondaryButton: .cancel(Text(AppConfigurator.Strings.no)) {
                    Task { viewModel.authenticationTrigger.send(.saveToken) }
                }
            )
        case .simple:
            return Alert(
                title: Text(alertInfo.title),
                message: Text(alertInfo.message),
                dismissButton: .default(Text(AppConfigurator.Strings.ok))
            )
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView(viewModel: LoginViewModel())
}
