//
//  CardPhoto.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import UIKit

/// A single photo associated with a card, providing async image loading.
public struct CardPhoto: Identifiable, Sendable {
    public let id: UUID
    public let cardSizeImageProvider: @Sendable () async -> UIImage?
    public let originalImageProvider: @Sendable () async -> UIImage?

    public init(
        id: UUID = UUID(),
        cardSizeImageProvider: @escaping @Sendable () async -> UIImage?,
        originalImageProvider: @escaping @Sendable () async -> UIImage?
    ) {
        self.id = id
        self.cardSizeImageProvider = cardSizeImageProvider
        self.originalImageProvider = originalImageProvider
    }
}
