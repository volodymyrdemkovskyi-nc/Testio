//
//  UserAuthServiceTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 29/06/2025.
//

import XCTest
@testable import Testio

class UserAuthServiceTests: XCTestCase {
    var authService: UserAuthService!
    var mockNetwork: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkManager()
        authService = UserAuthService(networkManager: mockNetwork)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testObtainAuthTokenSuccess() async {
        mockNetwork.postResponse = Authorization(token: "successToken")
        let creds = UserСredentials(username: "user", password: "pass")
        let auth = try? await authService.obtainAuthToken(forUser: creds)
        XCTAssertEqual(auth?.token, "successToken")
    }

    func testObtainAuthTokenFailure() async {
        mockNetwork.errorToThrow = .accessDenied
        let creds = UserСredentials(username: "user", password: "pass")
        do {
            _ = try await authService.obtainAuthToken(forUser: creds)
            XCTFail("Should have thrown error")
        } catch NetworkManager.NetworkError.accessDenied {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
