//
//  CardCarouselConfiguration.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 02/04/2026.
//

import Foundation

/// Configurable parameters for the card carousel appearance and layout.
///
/// Pass a custom configuration to `CardCarouselView` to override defaults.
/// All values have sensible defaults matching the original hardcoded behavior.
public struct CardCarouselConfiguration: Sendable {

    // MARK: - Side Card Appearance

    /// Scale factor for non-centered cards (0.0–1.0). Default: 0.93.
    public var sideCardScale: CGFloat

    /// Opacity for non-centered cards (0.0–1.0). Default: 0.6.
    public var sideCardOpacity: Double

    // MARK: - iPhone Portrait Layout

    /// Card height as a fraction of container height. Default: 0.85.
    public var phonePortraitHeightFraction: CGFloat

    /// Card width as a fraction of container width. Default: 0.75.
    public var phonePortraitWidthFraction: CGFloat

    // MARK: - Spacing

    /// Gap between adjacent cards. Default: 12.
    public var interCardSpacing: CGFloat

    public init(
        sideCardScale: CGFloat = 0.93,
        sideCardOpacity: Double = 0.6,
        phonePortraitHeightFraction: CGFloat = 0.85,
        phonePortraitWidthFraction: CGFloat = 0.75,
        interCardSpacing: CGFloat = 12
    ) {
        self.sideCardScale = sideCardScale
        self.sideCardOpacity = sideCardOpacity
        self.phonePortraitHeightFraction = phonePortraitHeightFraction
        self.phonePortraitWidthFraction = phonePortraitWidthFraction
        self.interCardSpacing = interCardSpacing
    }

    /// Default configuration matching the original hardcoded values.
    public static let `default` = CardCarouselConfiguration()
}
