//
//  KeyboardShiftHandler.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 28/06/2025.
//

import SwiftUI

extension View {
    func adjustForKeyboard() -> ModifiedContent<Self, KeyboardShiftHandler> {
        modifier(KeyboardShiftHandler())
    }
}

struct KeyboardShiftHandler: ViewModifier {
    @StateObject private var elevationMonitor = KeyboardEventManager()

    func body(content: Content) -> some View {
        content
            .offset(y: computeShiftAmount())
            .animation(.spring(response: AppConfigurator.Sizes.keyboardResponse,
                               dampingFraction: AppConfigurator.Sizes.keyboardDampingFraction),
                       value: elevationMonitor.keyboardRise)
    }

    private func computeShiftAmount() -> CGFloat {
        let adjustedRise = -elevationMonitor.keyboardRise * 0.33
        return min(adjustedRise, 200)
    }
}
