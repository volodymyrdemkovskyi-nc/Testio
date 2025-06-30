//
//  TestioApp.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 23/06/2025.
//

import SwiftUI

@main
struct TestioApp: App {
    var body: some Scene {
        WindowGroup {
            InitialView()
        }
        .modelContainer(for: Server.self)
    }
}
