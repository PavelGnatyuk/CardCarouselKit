//
//  CardCarouselLayout.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 25/03/2026.
//

import SwiftUI

/// Computes card dimensions and visible card count from available space and size classes.
///
/// Layout contexts per device/orientation:
/// - iPhone Portrait  (compact H, regular V):  3 cards, 75% height
/// - iPhone Landscape (compact H, compact V):  3 cards, 85% height
/// - iPad Portrait    (regular H, regular V):  5 cards, 65% height, max 320pt width
/// - iPad Landscape   (regular H, regular V):  5 cards, 80% height, max 320pt width
struct CardCarouselLayout {
    let cardHeight: CGFloat
    let cardWidth: CGFloat
    let visibleCardCount: Int
    let interCardSpacing: CGFloat

    /// Creates a layout from the available container size and current size classes.
    ///
    /// - Parameters:
    ///   - containerSize: Available size from GeometryReader.
    ///   - horizontalSizeClass: Current horizontal size class.
    ///   - verticalSizeClass: Current vertical size class.
    init(
        containerSize: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) {
        let isRegularWidth = horizontalSizeClass == .regular
        let isCompactHeight = verticalSizeClass == .compact

        if isRegularWidth {
            // iPad — distinguish portrait vs landscape by container aspect ratio
            let isLandscape = containerSize.width > containerSize.height
            let heightFraction: CGFloat = isLandscape ? 0.80 : 0.65
            let maxWidth: CGFloat = 320

            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: heightFraction,
                maxWidth: maxWidth
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.visibleCardCount = 5
            self.interCardSpacing = 16
        } else if isCompactHeight {
            // iPhone Landscape — cards are wide relative to short screen
            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: 0.85,
                maxWidth: containerSize.width * 0.45
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.visibleCardCount = 3
            self.interCardSpacing = 12
        } else {
            // iPhone Portrait — clamp width so side cards peek through
            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: 0.75,
                maxWidth: containerSize.width * 0.75
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.visibleCardCount = 3
            self.interCardSpacing = 12
        }
    }

    /// Computes card size from height fraction, clamping width to maxWidth
    /// and recalculating height to maintain 3:4 aspect ratio.
    private static func resolveCardSize(
        containerSize: CGSize,
        heightFraction: CGFloat,
        maxWidth: CGFloat
    ) -> CGSize {
        let computedHeight = containerSize.height * heightFraction
        let computedWidth = computedHeight * 3.0 / 4.0

        if computedWidth > maxWidth {
            // Width exceeds limit — clamp and derive height from clamped width
            return CGSize(width: maxWidth, height: maxWidth * 4.0 / 3.0)
        }
        return CGSize(width: computedWidth, height: computedHeight)
    }
}
