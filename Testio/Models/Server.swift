//
//  Server.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 27/06/2025.
//

import SwiftData

@Model
class Server: Hashable, Decodable {
    var serverName: String
    var serverDistance: Int

    enum CodingKeys: String, CodingKey {
        case serverName = "name"
        case serverDistance = "distance"
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .serverName)
        let distance = try container.decode(Int.self, forKey: .serverDistance)
        self.init(serverName: name, serverDistance: distance)
    }

    init(serverName: String, serverDistance: Int) {
        self.serverName = serverName
        self.serverDistance = serverDistance
    }

    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.serverName == rhs.serverName && lhs.serverDistance == rhs.serverDistance
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(serverName)
        hasher.combine(serverDistance)
    }
}

extension Server {
    var formattedDistance: String {
        String(serverDistance)
    }
}
