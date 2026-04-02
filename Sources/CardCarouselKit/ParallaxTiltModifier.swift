//
//  ParallaxTiltModifier.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 02/04/2026.
//

import SwiftUI

/// Applies a subtle 3D parallax tilt based on provided pitch and roll values.
///
/// Pure visual transform — no CoreMotion dependency. The host app provides
/// motion data via `CardCarouselState.parallaxPitch` / `.parallaxRoll`.
/// Includes a slight scale-up to prevent edge gaps during offset.
/// Fully disabled when `accessibilityReduceMotion` is on.
struct ParallaxTiltModifier: ViewModifier {
    let pitch: Double
    let roll: Double
    let maxRotationDegrees: Double
    let maxOffset: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : 1.04)
            .rotation3DEffect(
                .degrees(reduceMotion ? 0 : roll * maxRotationDegrees),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(reduceMotion ? 0 : -pitch * maxRotationDegrees),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .offset(
                x: reduceMotion ? 0 : roll * maxOffset,
                y: reduceMotion ? 0 : -pitch * maxOffset
            )
            .animation(
                .interpolatingSpring(stiffness: 50, damping: 12),
                value: roll
            )
            .animation(
                .interpolatingSpring(stiffness: 50, damping: 12),
                value: pitch
            )
    }
}

extension View {
    /// Applies a subtle 3D parallax tilt using provided motion values.
    func parallaxTilt(
        pitch: Double,
        roll: Double,
        maxDegrees: Double = 6,
        maxOffset: CGFloat = 8
    ) -> some View {
        modifier(ParallaxTiltModifier(
            pitch: pitch,
            roll: roll,
            maxRotationDegrees: maxDegrees,
            maxOffset: maxOffset
        ))
    }
}
