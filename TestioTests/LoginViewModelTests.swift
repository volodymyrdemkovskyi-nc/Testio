//
//  LoginViewModelTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 30/06/2025.
//

import XCTest
import Combine
@testable import Testio

class MockUserAuthService: UserAuthServiceProtocol {
    var tokenToReturn: Authorization?
    var errorToThrow: Error?

    func obtainAuthToken(forUser: UserCredentials) async throws -> Authorization {
        if let error = errorToThrow { throw error }
        return tokenToReturn ?? Authorization(token: "mockToken")
    }
}

@MainActor
class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var loginState: LoginState!
    var mockAuth: MockUserAuthService!

    override func setUp() {
        super.setUp()
        loginState = LoginState()
        loginState.usernameInput = ""
        loginState.passwordInput = ""
        mockAuth = MockUserAuthService()
        viewModel = LoginViewModel(loginState: loginState, userAuthService: mockAuth)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyInput() {
        let expectation = XCTestExpectation(description: "Alert update")
        loginState.loginTrigger.send()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(self.viewModel.alertInfo)
            XCTAssertEqual(self.viewModel.alertInfo?.title, AppConfigurator.Strings.verificationFailed)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSuccessfulLogin() async {
        let expectation = XCTestExpectation(description: "Login completion")
        loginState.usernameInput = "user"
        loginState.passwordInput = "pass"
        mockAuth.tokenToReturn = Authorization(token: "successToken")
        loginState.loginTrigger.send()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.viewModel.isAuthenticated)
            XCTAssertNil(self.viewModel.alertInfo)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1)
    }
}
