//
//  CardCarouselDataSource.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import Foundation

/// Protocol for the host app to supply cards and receive carousel events.
@MainActor
public protocol CardCarouselDataSource: AnyObject {
    /// Called when the carousel needs the next card after the given index.
    func carouselDidRequestNextCard(after index: Int) async -> CardItem?

    /// Called when the carousel needs the previous card before the given index.
    func carouselDidRequestPreviousCard(before index: Int) async -> CardItem?

    /// Called when the user taps a special card.
    func carouselDidTapSpecialCard(_ card: CardItem)

    /// Called when the user taps a photo on a card.
    func carouselDidTapPhoto(card: CardItem, photoIndex: Int)

    /// Called when the visible window shifts.
    func carouselWindowDidShift(visibleIndices: Range<Int>)
}
