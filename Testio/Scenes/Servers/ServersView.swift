//
//  ServersViewModel.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import SwiftUI
import SwiftData

struct ServersView: View {
    @ObservedObject var viewModel = ServersViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var servers: [Server]

    @State private var isSortTapped: Bool = false
    @State private var isExitTapped: Bool = false
    @State private var isSortOptionsVisible: Bool = false
    @State private var currentFilter: ServersViewModel.FilterType?

    var body: some View {
        VStack {
            topHeaderView

            serverDisplayArea
        }
        .task {
            await viewModel.fetchAndSaveServers(using: modelContext)
        }
    }

    private var sortedServers: [Server] {
        if let filter = currentFilter {
            return viewModel.sort(servers: servers, by: filter)
        } else {
            return servers
        }
    }
}

// MARK: - View Components
private extension ServersView {
    var topHeaderView: some View {
        HStack {
            sortOptionButton

            Spacer()

            Text(AppConfigurator.Strings.testioLogo)
                .font(AppConfigurator.Fonts.header)
                .frame(maxWidth: .infinity)

            Spacer()

            exitOptionButton
        }
    }

    var sortOptionButton: some View {
        TestioButton(
            buttonText: AppConfigurator.Strings.filter,
            leadingIcon: AppConfigurator.Images.sort.image,
            backgroundColor: .white,
            textColor: AppConfigurator.Colors.primaryButtonColor,
            isTapped: $isSortTapped
        )
        .confirmationDialog("", isPresented: $isSortOptionsVisible, titleVisibility: .hidden) {
            Button(AppConfigurator.Strings.byDistance) {
                currentFilter = .distance
            }
            Button(AppConfigurator.Strings.alphabetical) {
                currentFilter = .alphabet
            }
        }
        .onChange(of: isSortTapped) {
            if isSortTapped {
                isSortOptionsVisible.toggle()
                isSortTapped = false
            }
        }
    }

    var exitOptionButton: some View {
        TestioButton(
            buttonText: AppConfigurator.Strings.logout,
            trailingIcon: AppConfigurator.Images.logout.image,
            backgroundColor: .white,
            textColor: AppConfigurator.Colors.primaryButtonColor,
            isTapped: $isExitTapped
        )
        .onChange(of: isExitTapped) {
            if isExitTapped {
                viewModel.logoutUserAndRemoveServers(using: modelContext)
                isExitTapped = false
            }
        }
    }

    var serverDisplayArea: some View {
        List {
            Section(
                header: createRow(AppConfigurator.Strings.server,
                                  AppConfigurator.Strings.distance)
            ) {
                ForEach(sortedServers, id: \.self) { data in
                    createRow(data.serverName, data.formattedDistance)
                        .padding(.vertical, AppConfigurator.Sizes.padding_10)
                        .listRowInsets(EdgeInsets(top: .zero,
                                                  leading: AppConfigurator.Sizes.padding_16,
                                                  bottom: .zero,
                                                  trailing: AppConfigurator.Sizes.padding_16))
                }
            }
        }
        .listStyle(.grouped)
    }

    func createRow(_ firstText: String, _ secondText: String) -> some View {
        HStack {
            Text(firstText)
            Spacer()
            Text(secondText)
        }
    }
}

// MARK: - Preview
#Preview {
    ServersView()
}

