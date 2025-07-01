//
//  BiometricManager.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 01/07/2025.
//

import SwiftUI
import LocalAuthentication

protocol BiometricManagerProtocol {
    func checkBiometricAvailability() -> (biometricType: BiometricType?, error: LAError?)
    func authenticateWithBiometrics() async -> (isAuthenticated: Bool, error: LAError?)
    func navigateToSettings() async throws
}

enum BiometricType {
    case unknown
    case touchID
    case faceID
}

final class BiometricManager: BiometricManagerProtocol {
    private let context = LAContext()

    func checkBiometricAvailability() -> (biometricType: BiometricType?, error: LAError?) {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID:
                return (.touchID, nil)
            case .faceID:
                return (.faceID, nil)
            default:
                return (.unknown, nil)
            }
        } else {
            return (nil, error as? LAError)
        }
    }

    func authenticateWithBiometrics() async -> (isAuthenticated: Bool, error: LAError?) {
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: AppConfigurator.Strings.biometricAuthenticationTitle) { success, error in
                continuation.resume(returning: (success, error as? LAError))
            }
        }
    }

    func navigateToSettings() async throws {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create settings URL"])
        }

        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                UIApplication.shared.open(settingsUrl, options: [:]) { accepted in
                    if accepted {
                        continuation.resume()
                    } else {
                        let error = NSError(domain: "Navigation Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to open settings."])
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
