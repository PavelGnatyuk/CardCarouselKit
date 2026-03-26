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
/// Aspect ratio is always 3:4 (width:height).
struct CardCarouselLayout {
    let cardHeight: CGFloat
    let cardWidth: CGFloat

    /// Gap between adjacent cards in the carousel.
    let interCardSpacing: CGFloat

    /// Horizontal content margin so the first/last card centers in the viewport.
    let horizontalContentMargin: CGFloat

    init(
        containerSize: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) {
        let isRegularWidth = horizontalSizeClass == .regular
        let isCompactHeight = verticalSizeClass == .compact

        if isRegularWidth {
            // iPad
            let isLandscape = containerSize.width > containerSize.height
            let heightFraction: CGFloat = isLandscape ? 0.80 : 0.65
            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: heightFraction,
                maxWidth: min(320, containerSize.width * 0.45)
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.interCardSpacing = 0
        } else if isCompactHeight {
            // iPhone Landscape
            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: 0.85,
                maxWidth: containerSize.width * 0.45
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.interCardSpacing = 0
        } else {
            // iPhone Portrait — card takes ~85% of width, margins show neighbor peeks
            let resolved = Self.resolveCardSize(
                containerSize: containerSize,
                heightFraction: 0.75,
                maxWidth: containerSize.width * 0.85
            )
            self.cardWidth = resolved.width
            self.cardHeight = resolved.height
            self.interCardSpacing = 0
        }

        self.horizontalContentMargin = (containerSize.width - cardWidth) / 2
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
            return CGSize(width: maxWidth, height: maxWidth * 4.0 / 3.0)
        }
        return CGSize(width: computedWidth, height: computedHeight)
    }
}
