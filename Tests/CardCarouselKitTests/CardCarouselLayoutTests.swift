// Created by Pavel Gnatyuk

import Testing
import SwiftUI
@testable import CardCarouselKit

@Suite("CardCarouselLayout -- iPhone Portrait", .tags(.pureLogic))
struct CardCarouselLayoutiPhonePortraitTests {

    // iPhone portrait: compact width, regular height
    private let containerSize = CGSize(width: 393, height: 759)
    private let horizontalSizeClass: UserInterfaceSizeClass? = .compact
    private let verticalSizeClass: UserInterfaceSizeClass? = .regular

    /// Description: Verifies iPhone portrait card height is 79% of container.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone portrait size classes
    /// 2. Verify cardHeight equals 79% of container height
    @Test
    func cardHeight() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        let expected = containerSize.height * 0.79
        #expect(layout.cardHeight == expected)
    }

    /// Description: Verifies iPhone portrait card width is 72% of container.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone portrait size classes
    /// 2. Verify cardWidth equals 72% of container width
    @Test
    func cardWidth() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        let expected = containerSize.width * 0.72
        #expect(layout.cardWidth == expected)
    }

    /// Description: Verifies iPhone portrait is not landscape.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone portrait size classes
    /// 2. Verify isLandscape is false
    @Test
    func isNotLandscape() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        #expect(!layout.isLandscape)
    }

    /// Description: Verifies horizontal margin centers the card in the container.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone portrait size classes
    /// 2. Verify horizontalContentMargin equals (containerWidth - cardWidth) / 2
    @Test
    func horizontalMarginCentersCard() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        let expected = (containerSize.width - layout.cardWidth) / 2
        #expect(layout.horizontalContentMargin == expected)
    }
}

@Suite("CardCarouselLayout -- iPhone Landscape", .tags(.pureLogic))
struct CardCarouselLayoutiPhoneLandscapeTests {

    // iPhone landscape: compact width, compact height
    private let containerSize = CGSize(width: 852, height: 393)
    private let horizontalSizeClass: UserInterfaceSizeClass? = .compact
    private let verticalSizeClass: UserInterfaceSizeClass? = .compact

    /// Description: Verifies iPhone landscape is detected as landscape.
    ///
    /// Scenario:
    /// 1. Create layout with compact height
    /// 2. Verify isLandscape is true
    @Test
    func isLandscape() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        #expect(layout.isLandscape)
    }

    /// Description: Verifies iPhone landscape card subtracts toolbar space from height.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone landscape size classes
    /// 2. Verify cardHeight does not exceed container height minus toolbar (60 + 16 + 16)
    @Test
    func cardHeightSubtractsToolbar() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        let maxAvailableHeight = containerSize.height - 60 - 16 - 16
        #expect(layout.cardHeight <= maxAvailableHeight)
        #expect(layout.cardHeight > 0)
    }

    /// Description: Verifies iPhone landscape card width does not exceed 30% of container.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone landscape size classes
    /// 2. Verify cardWidth is at most 30% of container width
    @Test
    func cardWidthCappedAt30Percent() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        #expect(layout.cardWidth <= containerSize.width * 0.30)
    }

    /// Description: Verifies inter-card spacing is 12 in landscape.
    ///
    /// Scenario:
    /// 1. Create layout with iPhone landscape size classes
    /// 2. Verify interCardSpacing is 12
    @Test
    func interCardSpacing() {
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        #expect(layout.interCardSpacing == 12)
    }
}

@Suite("CardCarouselLayout -- iPad", .tags(.pureLogic))
struct CardCarouselLayoutiPadTests {

    /// Description: Verifies iPad portrait uses 65% height fraction.
    ///
    /// Scenario:
    /// 1. Create layout with iPad portrait dimensions (regular width, taller than wide)
    /// 2. Verify cardHeight does not exceed 65% of container height
    @Test
    func iPadPortraitHeight() {
        let containerSize = CGSize(width: 820, height: 1180)
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: .regular,
            verticalSizeClass: .regular
        )

        let maxHeight = containerSize.height * 0.65
        #expect(layout.cardHeight <= maxHeight)
        #expect(layout.cardHeight > 0)
    }

    /// Description: Verifies iPad landscape uses 80% height fraction.
    ///
    /// Scenario:
    /// 1. Create layout with iPad landscape dimensions (regular width, wider than tall)
    /// 2. Verify cardHeight does not exceed 80% of container height
    @Test
    func iPadLandscapeHeight() {
        let containerSize = CGSize(width: 1180, height: 820)
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: .regular,
            verticalSizeClass: .regular
        )

        let maxHeight = containerSize.height * 0.80
        #expect(layout.cardHeight <= maxHeight)
        #expect(layout.cardHeight > 0)
    }

    /// Description: Verifies iPad card width never exceeds 320pt.
    ///
    /// Scenario:
    /// 1. Create layout with large iPad container
    /// 2. Verify cardWidth is at most 320pt
    @Test
    func cardWidthCappedAt320() {
        let containerSize = CGSize(width: 1180, height: 820)
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: .regular,
            verticalSizeClass: .regular
        )

        #expect(layout.cardWidth <= 320)
    }

    /// Description: Verifies iPad card maintains approximately 3:4 aspect ratio.
    ///
    /// Scenario:
    /// 1. Create layout with iPad portrait dimensions
    /// 2. Compute actual ratio (width/height)
    /// 3. Verify it is close to 0.75 (3/4)
    @Test
    func aspectRatioApproximately3to4() {
        let containerSize = CGSize(width: 820, height: 1180)
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: .regular,
            verticalSizeClass: .regular
        )

        let ratio = layout.cardWidth / layout.cardHeight
        #expect(abs(ratio - 0.75) < 0.01)
    }

    /// Description: Verifies horizontal margin centers the card on iPad.
    ///
    /// Scenario:
    /// 1. Create layout with iPad dimensions
    /// 2. Verify margin equals (containerWidth - cardWidth) / 2
    @Test
    func horizontalMarginCentersCard() {
        let containerSize = CGSize(width: 820, height: 1180)
        let layout = CardCarouselLayout(
            containerSize: containerSize,
            horizontalSizeClass: .regular,
            verticalSizeClass: .regular
        )

        let expected = (containerSize.width - layout.cardWidth) / 2
        #expect(layout.horizontalContentMargin == expected)
    }
}
