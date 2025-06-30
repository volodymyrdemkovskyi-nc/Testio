//
//  AnimatedLogo.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 30/06/2025.
//

import SwiftUI

struct AnimatedLogo: View {
    
    @State private var animationProgress: CGFloat = .zero
    private let duration: Double = AppConfigurator.Sizes.logoAnimationDuration
    private let scaleIncrease: CGFloat = AppConfigurator.Sizes.logoScaleIncrease

    var body: some View {
        AppConfigurator.Images.logo.image?
            .resizable()
            .frame(width: AppConfigurator.Sizes.logoWidth,
                   height: AppConfigurator.Sizes.logoHeight)
            .scaleEffect(1.0 + animationProgress * scaleIncrease)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    animationProgress = 1.0
                }
            }
    }
}
