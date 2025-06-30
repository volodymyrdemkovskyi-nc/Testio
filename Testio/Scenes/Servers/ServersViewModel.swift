//
//  ServersViewModel.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import Foundation
import SwiftData

class ServersViewModel: ObservableObject {

    enum FilterType: CaseIterable {
        case distance
        case alphabet

        var text: String {
            switch self {
            case .distance:
                return AppConfigurator.Strings.byDistance
            case .alphabet:
                return AppConfigurator.Strings.alphabetical
            }
        }
    }

    private let service: ServerDataServiceProtocol

    init(service: ServerDataServiceProtocol = ServerDataService()) {
        self.service = service
    }

}

extension ServersViewModel {

    func fetchAndSaveServers(using context: ModelContext) async {
        guard let returnedData = try? await service.fetchServerList() else { return }

        for server in returnedData {
            context.insert(server)
        }

        do {
            try context.save()
        } catch {
            print("Failed saving context: \(error)")
        }
    }

    func logoutUserAndRemoveServers(using context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Server>()
        if let allServers = try? context.fetch(fetchDescriptor) {
            for server in allServers {
                context.delete(server)
            }

            do {
                try context.save()
            } catch {
                print("Failed saving context: \(error)")
            }
        }

        AuthenticationSessionHandler.shared.clearSessionToken()
    }

    func sort(servers: [Server], by filter: FilterType) -> [Server] {
        switch filter {
        case .distance:
            return servers.sorted { $0.serverDistance < $1.serverDistance }
        case .alphabet:
            return servers.sorted { $0.serverName < $1.serverName }
        }
    }
}
