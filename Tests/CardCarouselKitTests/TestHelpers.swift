// Created by Pavel Gnatyuk

@testable import CardCarouselKit

/// Creates a minimal CardItem for testing with no photos.
func makeCardItem(title: String = "Card") -> CardItem {
    CardItem(
        photos: [],
        title: title,
        subtitle: "",
        descriptionMarkdown: "",
        cardType: .regular
    )
}

/// Creates an array of CardItems with sequential titles.
func makeCardItems(count: Int) -> [CardItem] {
    (0..<count).map { makeCardItem(title: "Card \($0)") }
}
