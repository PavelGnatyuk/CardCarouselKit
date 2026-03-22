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

    public init() {}
}
