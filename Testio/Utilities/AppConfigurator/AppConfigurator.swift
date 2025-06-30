//
//  AppConfigurator.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 24/06/2025.
//

import SwiftUI

struct AppConfigurator {

    struct Sizes {
        static let padding_8: CGFloat = 8
        static let padding_10: CGFloat = 10
        static let padding_12: CGFloat = 12
        static let padding_16: CGFloat = 16
        static let padding_20: CGFloat = 20
        static let padding_32: CGFloat = 32

        static let defaultIconSize: CGFloat = 16
        static let defaultCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 40
        static let buttonMinOpacity: CGFloat = 0.8
        static let buttonMaxOpacity: CGFloat = 1.0
        static let keyboardResponse: CGFloat = 0.35
        static let keyboardDampingFraction: CGFloat = 0.7
        static let textFieldTextOpacityMin: CGFloat = 0.6
        static let textFieldTextOpacityMax: CGFloat = 1.0
        static let loginSpacing: CGFloat = 40
        static let logoWidth: CGFloat = 186
        static let logoHeight: CGFloat = 48
        static let logoScaleIncrease: CGFloat = 0.25 
        static let logoAnimationDuration: Double = 3.0
    }

    struct Images {
        static let logo = "logoIcon"
        static let background = "backgroundIcon"
        static let username = "usernameIcon"
        static let password = "passwordIcon"
        static let logout = "logoutIcon"
        static let sort = "sortIcon"
    }

    struct URLs {
        private static let base = "https://playground.nordsec.com/v1"
        static var Servers: URL? { "\(base)/servers".url }
        static var Tokens: URL? { "\(base)/tokens".url }
    }

    struct Strings {
        static let username = "Username"
        static let password = "Password"
        static let login = "Log in"
        static let verificationFailed = "Verification Failed"
        static let incorrectUsername = "Your username or password is incorrect."
        static let ok = "OK"
        static let testioLogo = "Testio."
        static let loading = "Loading list"
        static let errorTitle = "Error"
        static let filter = "Filter"
        static let logout = "Logout"
        static let server = "Server"
        static let distance = "Distance"
        static let byDistance = "By distance"
        static let alphabetical = "Alphabetical"
        static let cancel = "Cancel"
    }

    struct Colors {
        static let inputFieldTextColor = Color("TextFieldTextColor")
        static let primaryButtonColor = Color("PrimaryCP1Light")
        static let inputFieldBackgroundColor = Color("TextFieldBackgroundColor")
    }

    struct Fonts {
        static var basic: Font { .system(size: 17) }
        static var header: Font { .system(size: 17, weight: .heavy) }
        static var loading: Font { .system(size: 13) } 
    }
}

