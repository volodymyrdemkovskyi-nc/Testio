//
//  TestioTests.swift
//  TestioTests
//
//  Created by Volodymyr Demkovskyi  on 23/06/2025.
//

import XCTest
@testable import Testio

class ModelsTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAlertInfoInitialization() {
        let alert = AlertInfo(title: "Error", message: "Failed")
        XCTAssertEqual(alert.title, "Error")
        XCTAssertEqual(alert.message, "Failed")
    }

    func testAuthorizationEncodingDecoding() throws {
        let auth = Authorization(token: "testToken")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(auth)
        let decodedAuth = try decoder.decode(Authorization.self, from: data)
        XCTAssertEqual(decodedAuth.token, "testToken")
    }

    func testUserCredentialsEncodingDecoding() throws {
        let creds = UserCredentials(username: "user", password: "pass")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(creds)
        let decodedCreds = try decoder.decode(UserCredentials.self, from: data)
        XCTAssertEqual(decodedCreds.username, "user")
        XCTAssertEqual(decodedCreds.password, "pass")
    }

    func testInitialization() {
        let server = Server(serverName: "Server1", serverDistance: 100)
        XCTAssertEqual(server.serverName, "Server1")
        XCTAssertEqual(server.serverDistance, 100)
    }

    func testDecoding() throws {
        let json = """
        {
            "name": "Server1",
            "distance": 150
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let server = try decoder.decode(Server.self, from: json)
        XCTAssertEqual(server.serverName, "Server1")
        XCTAssertEqual(server.serverDistance, 150)
    }

    func testEquality() {
        let server1 = Server(serverName: "Server1", serverDistance: 100)
        let server2 = Server(serverName: "Server1", serverDistance: 100)
        let server3 = Server(serverName: "Server2", serverDistance: 200)
        XCTAssertEqual(server1, server2)
        XCTAssertNotEqual(server1, server3)
    }

    func testHashing() {
        let server1 = Server(serverName: "Server1", serverDistance: 100)
        let server2 = Server(serverName: "Server1", serverDistance: 100)
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        server1.hash(into: &hasher1)
        server2.hash(into: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testFormattedDistance() {
        let server = Server(serverName: "Server1", serverDistance: 100)
        XCTAssertEqual(server.formattedDistance, "100")
    }
}
