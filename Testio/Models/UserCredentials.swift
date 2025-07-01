//
//  UserСredentials.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 24/06/2025.
//

import SwiftUI
import Combine

class UserСredentials: ObservableObject, Codable {
    @Published var username: String = "" // "tesonet"
    @Published var password: String = "" // "partyanimal"

    init(username: String = "", password: String = "") {
        self.username = username
        self.password = password
    }

    // MARK: - Codable conformance
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }
}
