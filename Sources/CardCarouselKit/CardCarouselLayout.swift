//
//  CardCarouselLayout.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 25/03/2026.
//

import SwiftUI

/// Computes card dimensions from available space and size classes.
///
/// The card is always centered within the full container width.
/// Neighboring cards peek in the margins.
///
/// Layout rules by context:
/// - iPhone portrait (compact width, regular height): 79% height, 72% width
/// - iPhone landscape (compact width, compact height): 85% height, 45% max width
/// - iPad portrait (regular width, regular height): 65% height, 50% max width
/// - iPad landscape (regular width, wider than tall): 80% height, 38% max width
struct CardCarouselLayout {
    let cardHeight: CGFloat
    let cardWidth: CGFloat

    /// Gap between adjacent cards in the carousel.
    let interCardSpacing: CGFloat

    /// Horizontal content margin so the first/last card centers in the viewport.
    let horizontalContentMargin: CGFloat

    /// Whether the device is in landscape orientation (compact height).
    let isLandscape: Bool

    init(
        containerSize: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) {
        let isRegularWidth = horizontalSizeClass == .regular
        let isCompactHeight = verticalSizeClass == .compact
        self.isLandscape = isCompactHeight

        if isRegularWidth {
            // iPad — both portrait and landscape
            let isLandscape = containerSize.width > containerSize.height
            let heightFraction: CGFloat = isLandscape ? 0.80 : 0.65
            let maxWidth: CGFloat = isLandscape
                ? containerSize.width * 0.38
                : containerSize.width * 0.50

            let computedHeight = containerSize.height * heightFraction
            let computedWidth = computedHeight * 3.0 / 4.0

            if computedWidth > maxWidth {
                self.cardWidth = maxWidth
                self.cardHeight = maxWidth * 4.0 / 3.0
            } else {
                self.cardWidth = computedWidth
                self.cardHeight = computedHeight
            }
            self.interCardSpacing = 12
        } else if isCompactHeight {
            // iPhone Landscape — subtract toolbar space so card never overlaps
            let toolbarHeight: CGFloat = 60
            let toolbarPadding: CGFloat = 16
            let gap: CGFloat = 16
            let computedHeight = containerSize.height - toolbarHeight - toolbarPadding - gap
            let computedWidth = computedHeight * 3.0 / 4.0
            let maxWidth = containerSize.width * 0.30

            if computedWidth > maxWidth {
                self.cardWidth = maxWidth
                self.cardHeight = min(maxWidth * 4.0 / 3.0, computedHeight)
            } else {
                self.cardWidth = computedWidth
                self.cardHeight = computedHeight
            }
            self.interCardSpacing = 12
        } else {
            // iPhone Portrait — height-driven, 79% of available height
            self.cardHeight = containerSize.height * 0.79
            self.cardWidth = containerSize.width * 0.72
            self.interCardSpacing = 12
        }

        self.horizontalContentMargin = (containerSize.width - cardWidth) / 2
    }
}
