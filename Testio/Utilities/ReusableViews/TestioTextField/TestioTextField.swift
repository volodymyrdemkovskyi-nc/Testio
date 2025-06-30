//
//  TestioTextField.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 26/06/2025.
//

import SwiftUI

struct TestioTextField: View {
    // MARK: - Properties
    @Binding private var inputText: String
    @FocusState private var isFocused: Bool

    private let inputPlaceholder: String
    private let fieldIcon: Image?
    private let maxWidth: CGFloat?

    // MARK: - Initialization
    init(
        inputText: Binding<String>,
        inputPlaceholder: String,
        fieldIcon: Image? = nil,
        maxWidth: CGFloat? = nil
    ) {
        self._inputText = inputText
        self.inputPlaceholder = inputPlaceholder
        self.fieldIcon = fieldIcon
        self.maxWidth = maxWidth
    }

    // MARK: - View Body
    var body: some View {
        HStack {
            if let icon = fieldIcon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .opacity(iconOpacity)
                    .padding(.vertical, AppConfigurator.Sizes.padding_12)
                    .padding(.horizontal, AppConfigurator.Sizes.padding_8)
            }

            TextField(
                "",
                text: $inputText,
                prompt: Text(inputPlaceholder)
                    .foregroundStyle(AppConfigurator.Colors.inputFieldTextColor.opacity(AppConfigurator.Sizes.textFieldTextOpacityMin))
            )
            .foregroundColor(AppConfigurator.Colors.inputFieldTextColor.opacity(AppConfigurator.Sizes.textFieldTextOpacityMax))
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .focused($isFocused)
            .font(AppConfigurator.Fonts.basic)
            .padding(.vertical, AppConfigurator.Sizes.padding_12)
            .padding(.trailing, AppConfigurator.Sizes.padding_8)
        }
        .frame(maxWidth: maxWidth)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: AppConfigurator.Sizes.defaultCornerRadius))
    }

    // MARK: - Computed Properties
    private var iconOpacity: CGFloat {
        if inputText.isEmpty {
            return isFocused ? AppConfigurator.Sizes.textFieldTextOpacityMax : AppConfigurator.Sizes.textFieldTextOpacityMin
        } else {
            return AppConfigurator.Sizes.textFieldTextOpacityMax
        }
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppConfigurator.Sizes.defaultCornerRadius)
            .fill(AppConfigurator.Colors.inputFieldBackgroundColor)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Empty field
        TestioTextField(
            inputText: .constant(""),
            inputPlaceholder: "Username",
            fieldIcon: AppConfigurator.Images.username.image,
            maxWidth: .infinity
        )

        // Filed field
        TestioTextField(
            inputText: .constant("Volodymyr"),
            inputPlaceholder: "Username",
            fieldIcon: AppConfigurator.Images.username.image,
            maxWidth: .infinity
        )
    }
    .padding()
}
