//
//  PreviewHelpers.swift
//  CardCarouselKit
//

import SwiftUI

/// Creates a 300×400 solid-color UIImage for preview use.
func previewSolidColorImage(color: UIColor) -> UIImage {
    let size = CGSize(width: 300, height: 400)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

/// Creates a single preview CardItem with a solid-color photo.
func previewCardItem(
    color: UIColor,
    title: String,
    subtitle: String,
    descriptionMarkdown: String = "",
    cardType: CardType = .regular
) -> CardItem {
    let image = previewSolidColorImage(color: color)
    return CardItem(
        photos: [
            CardPhoto(
                cardSizeImageProvider: { image },
                originalImageProvider: { image }
            )
        ],
        title: title,
        subtitle: subtitle,
        descriptionMarkdown: descriptionMarkdown,
        cardType: cardType
    )
}

/// Creates test CardItems with solid-color images for previews.
func previewCardItems() -> [CardItem] {
    [
        previewCardItem(color: .systemRed, title: "Card One", subtitle: "First item"),
        previewCardItem(color: .systemGreen, title: "Card Two", subtitle: "Second item"),
        previewCardItem(color: .systemPurple, title: "Card Three", subtitle: "Third item"),
    ]
}

/// Creates a CardItem with multiple photos for multi-photo preview.
func previewMultiPhotoCardItem() -> CardItem {
    let colors: [UIColor] = [.systemBlue, .systemOrange, .systemTeal]
    let photos = colors.map { color in
        let image = previewSolidColorImage(color: color)
        return CardPhoto(
            cardSizeImageProvider: { image },
            originalImageProvider: { image }
        )
    }
    return CardItem(
        photos: photos,
        title: "Multi-Photo Card",
        subtitle: "3 photos",
        descriptionMarkdown: "",
        cardType: .regular
    )
}
