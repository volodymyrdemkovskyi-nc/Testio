//
//  KeyboardEventManager.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 29/06/2025.
//

import SwiftUI
import Combine

class KeyboardEventManager: ObservableObject {
    @Published var keyboardRise: CGFloat = 0

    private var observers: [NSObjectProtocol] = []

    init() {
        setupKeyboardObservers()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func setupKeyboardObservers() {
        let showObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.updateElevation(from: note)
        }

        let hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.keyboardRise = 0
        }

        observers.append(contentsOf: [showObserver, hideObserver])
    }

    private func updateElevation(from note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let newRise = frame.height * (1 - cos(frame.origin.y / frame.height))
        withAnimation {
            keyboardRise = newRise
        }
    }
}
