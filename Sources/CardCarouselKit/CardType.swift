//
//  CardType.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

/// Defines the behavior type for a card in the carousel.
public enum CardType: Sendable {
    /// Regular card: tap triggers flip animation (front ↔ back).
    case regular

    /// Special card: tap triggers callback only, no flip animation.
    case special
}
