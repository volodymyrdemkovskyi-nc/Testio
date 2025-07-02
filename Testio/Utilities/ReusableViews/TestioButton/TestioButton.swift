//
//  TestioButton.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 27/06/2025.
//

import SwiftUI

struct TestioButton: View {
    // MARK: - Properties
    private let buttonText: String
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let backgroundColor: Color
    private let textColor: Color
    @Binding var isTapped: Bool

    // MARK: - Initialization
    init(
        buttonText: String,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        backgroundColor: Color,
        textColor: Color,
        isTapped: Binding<Bool>
    ) {
        self.buttonText = buttonText
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self._isTapped = isTapped
    }

    // MARK: - View Body
    var body: some View {
        Button(action: {
            isTapped.toggle()
        }) {
            HStack(spacing: AppConfigurator.Sizes.padding_8) {
                leadingIcon
                    .foregroundColor(textColor)

                Text(buttonText)
                    .lineLimit(1)

                trailingIcon?
                    .foregroundColor(textColor)
            }
            .font(AppConfigurator.Fonts.basic)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConfigurator.Sizes.defaultCornerRadius))
        }
    }

    // MARK: - Background View
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: AppConfigurator.Sizes.defaultCornerRadius)
            .fill(backgroundColor)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var isTapped = false
    VStack(spacing: 20) {
        TestioButton(
            buttonText: AppConfigurator.Strings.login,
            backgroundColor: AppConfigurator.Colors.primaryButtonColor,
            textColor: .white,
            isTapped: $isTapped
        )

        TestioButton(
            buttonText: AppConfigurator.Strings.logout,
            trailingIcon: AppConfigurator.Images.logout.image,
            backgroundColor: .white,
            textColor: AppConfigurator.Colors.primaryButtonColor,
            isTapped: $isTapped
        )
    }
    .padding()
}
