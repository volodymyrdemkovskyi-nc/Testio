//
//  LoginViewModelTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 30/06/2025.
//

import XCTest
import Combine
@testable import Testio
import LocalAuthentication

class MockUserAuthService: UserAuthServiceProtocol {
    var tokenToReturn: Authorization?
    var errorToThrow: Error?

    func obtainAuthToken(forUser: UserСredentials) async throws -> Authorization {
        if let error = errorToThrow { throw error }
        return tokenToReturn ?? Authorization(token: "mockToken")
    }
}

class MockBiometricManager: BiometricManagerProtocol {
    var biometricAvailable: (BiometricType?, LAError?) = (.faceID, nil)
    var biometricAuthResult: (Bool, LAError?) = (true, nil)
    var shouldThrowNavigateError = false

    func checkBiometricAvailability() -> (biometricType: BiometricType?, error: LAError?) {
        return biometricAvailable
    }

    func authenticateWithBiometrics() async -> (isAuthenticated: Bool, error: LAError?) {
        return biometricAuthResult
    }

    func navigateToSettings() async throws {
        if shouldThrowNavigateError {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock navigation error"])
        }
    }
}

@MainActor
class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var loginState: UserСredentials!
    var mockAuth: MockUserAuthService!
    var mockBiometric: MockBiometricManager!
    var mockKeychain: MockKeychainManager!

    override func setUp() {
        super.setUp()
        loginState = UserСredentials()
        loginState.username = ""
        loginState.password = ""
        mockAuth = MockUserAuthService()
        mockBiometric = MockBiometricManager()
        mockKeychain = MockKeychainManager()
        viewModel = LoginViewModel(userAuthService: mockAuth, biometricManager: mockBiometric, keychainManager: mockKeychain)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Setup Tests

    func testSetupBindings_InitialState() {
        XCTAssertEqual(viewModel.authenticationStatus, .checkAuthenticationType)
        XCTAssertNil(viewModel.alertInfo)
    }

    // MARK: - Authorization Tests

    func testCheckAuthenticationType_NoCredentials() async {
        let expectation = XCTestExpectation(description: "No credentials case")
        viewModel.authenticationTrigger.send(.checkAuthenticationType)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.authenticationStatus, .checkAuthenticationType) // Remains unchanged if no credentials
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testCheckAuthenticationType_WithCredentialsAndBiometric() async {
        mockKeychain.storedData[.username] = "user"
        mockKeychain.storedData[.password] = "pass"
        let expectation = XCTestExpectation(description: "Biometric authentication trigger")
        viewModel.authenticationTrigger.send(.checkAuthenticationType)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testAuthorize_Successful() async {
        loginState.username = "user"
        loginState.password = "pass"
        mockAuth.tokenToReturn = Authorization(token: "successToken")
        let expectation = XCTestExpectation(description: "Successful authorization")
        viewModel.authenticationTrigger.send(.simpleAuthentication)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.authenticationStatus == .authorizedSimple || viewModel.authenticationStatus == .authorizedBiometric)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testAuthorize_Failure() async {
        loginState.username = "user"
        loginState.password = "pass"
        mockAuth.errorToThrow = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Auth failed"])
        let expectation = XCTestExpectation(description: "Authorization failure")
        viewModel.authenticationTrigger.send(.simpleAuthentication)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNotNil(viewModel.alertInfo)
        XCTAssertEqual(viewModel.alertInfo?.title, AppConfigurator.Strings.errorTitle)
        XCTAssertEqual(viewModel.alertInfo?.message, "Auth failed")
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testHandleBiometricAuthentication_Success() async {
        mockKeychain.storedData[.username] = "user"
        mockKeychain.storedData[.password] = "pass"
        mockAuth.tokenToReturn = Authorization(token: "bioToken")
        let expectation = XCTestExpectation(description: "Biometric auth success")
        viewModel.authenticationTrigger.send(.biometricAuthentication)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.authenticationStatus == .authorizedBiometric)
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testHandleBiometricAuthentication_Failure() async {
        mockBiometric.biometricAuthResult = (false, LAError(.authenticationFailed))
        let expectation = XCTestExpectation(description: "Biometric auth failure")
        viewModel.authenticationTrigger.send(.biometricAuthentication)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNotNil(viewModel.alertInfo)
        XCTAssertEqual(viewModel.alertInfo?.title, AppConfigurator.Strings.errorTitle)
        XCTAssertEqual(viewModel.alertInfo?.message, AppConfigurator.Strings.biometricAuthenticationFailed)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    // MARK: - Post-Authorization Tests

    func testHandleAuthorizedSimple_NoCredentials() async {
        let expectation = XCTestExpectation(description: "Save credentials prompt")
        viewModel.authenticationTrigger.send(.authorizedSimple)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNotNil(viewModel.alertInfo)
        XCTAssertEqual(viewModel.alertInfo?.title, AppConfigurator.Strings.saveCredentialsTitle)
        XCTAssertEqual(viewModel.alertInfo?.message, AppConfigurator.Strings.saveCredentialsMessage)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testHandleAuthorizedSimple_WithCredentials() async {
        mockKeychain.storedData[.username] = "user"
        mockKeychain.storedData[.password] = "pass"
        let expectation = XCTestExpectation(description: "Save token")
        viewModel.authenticationTrigger.send(.authorizedSimple)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testSaveCredentials_Success() async {
        loginState.username = "user"
        loginState.password = "pass"
        let expectation = XCTestExpectation(description: "Save credentials success")
        viewModel.authenticationTrigger.send(.saveBiometricData)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.authenticationStatus, .saveToken)
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testSaveCredentials_Failure() async {
        loginState.username = "user"
        loginState.password = "pass"
        mockKeychain.errorToThrow = .duplicateEntry
        let expectation = XCTestExpectation(description: "Save credentials failure")
        viewModel.authenticationTrigger.send(.saveBiometricData)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNotNil(viewModel.alertInfo)
        XCTAssertEqual(viewModel.alertInfo?.title, AppConfigurator.Strings.errorTitle)
        XCTAssertEqual(viewModel.alertInfo?.message, AppConfigurator.Strings.failedToSaveCredentials)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testHandleLoading() async {
        let expectation = XCTestExpectation(description: "Handle loading")
        viewModel.alertInfo = AlertInfo(title: "Test", message: "Test", type: .simple)
        viewModel.authenticationTrigger.send(.loading)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertNil(viewModel.alertInfo)
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1)
    }
}
