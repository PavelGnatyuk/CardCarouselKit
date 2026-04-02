//
//  CardCarouselState.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import Foundation

/// Observable state for the card carousel, shared between the carousel view and the host app.
@MainActor
@Observable
public final class CardCarouselState {
    public var currentCardIndex: Int = 0
    public var currentPhotoIndex: Int = 0
    public var isShimmerActive: Bool = false
    public var centeredCard: CardItem?

    /// Set by the host app to fade the carousel title during zoom transitions.
    public var isZoomTransitionActive: Bool = false

    /// Device motion values for parallax effect on the centered card photo.
    /// Set by the host app from CoreMotion. Default 0 = no parallax (opt-in).
    public var parallaxPitch: Double = 0
    public var parallaxRoll: Double = 0

    // MARK: - Flip State (per carousel position, not per card ID)

    private var flippedPositions: Set<Int> = []

    public func isFlipped(at position: Int) -> Bool {
        flippedPositions.contains(position)
    }

    public func toggleFlip(at position: Int) {
        if flippedPositions.contains(position) {
            flippedPositions.remove(position)
        } else {
            flippedPositions.insert(position)
        }
    }

    public func resetFlip(at position: Int) {
        flippedPositions.remove(position)
    }

    /// Resets flip state for all positions outside the visible window.
    public func resetFlipsOutsideWindow(center: Int, windowSize: Int = 1) {
        let visible = (center - windowSize)...(center + windowSize)
        flippedPositions = flippedPositions.filter { visible.contains($0) }
    }

    public init() {}
}
