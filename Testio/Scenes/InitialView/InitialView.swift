//
//  InitialView.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 24/06/2025.
//

import SwiftUI
import Combine

struct InitialView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var isUserLoggedIn = false 

    var body: some View {
        Group {
            isUserLoggedIn ? AnyView(ServersView()) : AnyView(LoginView(viewModel: loginViewModel))
        }
        .onReceive(AuthenticationSessionHandler.shared.authenticationStatusSubject) { isAuthenticated in
            isUserLoggedIn = isAuthenticated
        }
        .onAppear {
            isUserLoggedIn = AuthenticationSessionHandler.shared.checkSessionValidity()
        }
    }
}

#Preview {
    InitialView()
}
