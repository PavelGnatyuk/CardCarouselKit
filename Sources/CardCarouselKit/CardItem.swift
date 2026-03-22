//
//  CardItem.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import Foundation

/// A single card in the carousel with photos, text, and behavior type.
public struct CardItem: Identifiable, Sendable {
    public let id: UUID
    public let photos: [CardPhoto]
    public let title: String
    public let subtitle: String
    public let descriptionMarkdown: String
    public let cardType: CardType

    public init(
        id: UUID = UUID(),
        photos: [CardPhoto],
        title: String,
        subtitle: String,
        descriptionMarkdown: String,
        cardType: CardType
    ) {
        self.id = id
        self.photos = photos
        self.title = title
        self.subtitle = subtitle
        self.descriptionMarkdown = descriptionMarkdown
        self.cardType = cardType
    }
}
