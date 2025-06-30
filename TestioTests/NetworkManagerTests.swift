//
//  NetworkManagerTests.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 30/06/2025.
//

import XCTest
@testable import Testio

class MockNetworkManager: NetworkManagerProtocol {
    var getResponse: Decodable?
    var postResponse: Decodable?
    var errorToThrow: NetworkManager.NetworkError?
    var lastRequest: URLRequest?

    func executeGetRequest<T: Decodable>(atEndpoint: URL, expecting: T.Type, headers: [String: String]? = nil) async throws -> T {
        lastRequest = URLRequest(url: atEndpoint)
        if let error = errorToThrow { throw error }
        return getResponse as! T
    }

    func executePostRequest<T: Decodable, U: Encodable>(atEndpoint: URL, withPayload: U, expecting: T.Type, headers: [String: String]? = nil) async throws -> T {
        lastRequest = URLRequest(url: atEndpoint)
        if let error = errorToThrow { throw error }
        return postResponse as! T
    }
}

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockNetwork: MockNetworkManager!

    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
        mockNetwork = MockNetworkManager()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetRequestSuccess() async {
        let server = Server(serverName: "Server1", serverDistance: 100)
        mockNetwork.getResponse = [server]
        let servers = try? await mockNetwork.executeGetRequest(atEndpoint: URL(string: "https://test.com")!, expecting: [Server].self, headers: nil)
        XCTAssertEqual(servers?.first?.serverName, "Server1")
        XCTAssertEqual(servers?.first?.serverDistance, 100)
    }

    func testPostRequestSuccess() async {
        let auth = Authorization(token: "testToken")
        mockNetwork.postResponse = auth
        let creds = UserCredentials(username: "user", password: "pass")
        let result = try? await mockNetwork.executePostRequest(atEndpoint: URL(string: "https://test.com")!, withPayload: creds, expecting: Authorization.self, headers: nil)
        XCTAssertEqual(result?.token, "testToken")
    }

    func testGetRequestFailure() async {
        mockNetwork.errorToThrow = .accessDenied
        do {
            _ = try await mockNetwork.executeGetRequest(atEndpoint: URL(string: "https://test.com")!, expecting: [Server].self, headers: nil)
            XCTFail("Should have thrown error")
        } catch NetworkManager.NetworkError.accessDenied {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPostRequestFailure() async {
        mockNetwork.errorToThrow = .accessDenied
        let creds = UserCredentials(username: "user", password: "pass")
        do {
            _ = try await mockNetwork.executePostRequest(atEndpoint: URL(string: "https://test.com")!, withPayload: creds, expecting: Authorization.self, headers: nil)
            XCTFail("Should have thrown error")
        } catch NetworkManager.NetworkError.accessDenied {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
