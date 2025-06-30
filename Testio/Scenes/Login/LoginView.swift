//
//  LoginView.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 24/06/2025.
//

import SwiftUI
import Combine

struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            backgroundView

            if viewModel.isLoading {
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
            Alert(
                title: Text(viewModel.alertInfo?.title ?? ""),
                message: Text(viewModel.alertInfo?.message ?? ""),
                dismissButton: .default(Text(AppConfigurator.Strings.ok))
            )
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
