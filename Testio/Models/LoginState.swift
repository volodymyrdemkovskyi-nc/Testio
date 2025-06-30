//
//  LoginState.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import SwiftUI
import Combine

class LoginState: ObservableObject {
    @Published var usernameInput: String = "tesonet"
    @Published var passwordInput: String = "partyanimal"
    let loginTrigger = PassthroughSubject<Void, Never>()

    init() {}
}
