//
//  Untitled.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 30/06/2025.
//

import XCTest
@testable import Testio

class ServerDataServiceTests: XCTestCase {
    var serverService: ServerDataService!
    var mockNetwork: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkManager()
        serverService = ServerDataService(networkManager: mockNetwork)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFetchServerListSuccess() async {
        mockNetwork.getResponse = [Server(serverName: "Server1", serverDistance: 100)]
        let servers = try? await serverService.fetchServerList()
        XCTAssertEqual(servers?.first?.serverName, "Server1")
    }

    func testFetchServerListFailure() async {
        mockNetwork.errorToThrow = .accessDenied
        do {
            _ = try await serverService.fetchServerList()
            XCTFail("Should have thrown error")
        } catch NetworkManager.NetworkError.accessDenied {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
