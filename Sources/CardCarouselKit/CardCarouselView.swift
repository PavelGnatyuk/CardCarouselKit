//
//  CardCarouselView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import SwiftUI

/// The main carousel view. Displays cards in a horizontally scrollable layout.
///
/// Cards snap to center on swipe. Layout adapts to device and orientation
/// using size classes (3 cards on iPhone, 5 on iPad).
public struct CardCarouselView: View {
    let state: CardCarouselState
    let dataSource: (any CardCarouselDataSource)?
    let items: [CardItem]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var scrolledID: UUID?

    public init(
        state: CardCarouselState,
        dataSource: (any CardCarouselDataSource)? = nil,
        items: [CardItem] = []
    ) {
        self.state = state
        self.dataSource = dataSource
        self.items = items
    }

    public var body: some View {
        GeometryReader { geometry in
            let layout = CardCarouselLayout(
                containerSize: geometry.size,
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: layout.interCardSpacing) {
                    ForEach(items) { item in
                        CardFrontView(item: item)
                            .frame(width: layout.cardWidth, height: layout.cardHeight)
                            .opacity(item.id == scrolledID ? 1.0 : 0.6)
                            .scaleEffect(item.id == scrolledID ? 1.0 : 0.92)
                            .animation(.easeInOut(duration: 0.25), value: scrolledID)
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, horizontalPadding(layout: layout, containerWidth: geometry.size.width))
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .scrollClipDisabled()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: scrolledID) { _, newID in
            guard let newID else { return }
            if let index = items.firstIndex(where: { $0.id == newID }) {
                state.currentCardIndex = index
                state.centeredCard = items[index]
            }
        }
        .onAppear {
            if scrolledID == nil, let first = items.first {
                scrolledID = first.id
                state.centeredCard = first
                state.currentCardIndex = 0
            }
        }
    }

    /// Horizontal padding so the first and last cards can center in the scroll view.
    private func horizontalPadding(layout: CardCarouselLayout, containerWidth: CGFloat) -> CGFloat {
        (containerWidth - layout.cardWidth) / 2.0
    }
}

// MARK: - Preview

#Preview("Carousel — 3 cards") {
    CardCarouselView(
        state: CardCarouselState(),
        items: previewCardItems()
    )
}

#Preview("Carousel — Empty") {
    CardCarouselView(
        state: CardCarouselState(),
        items: []
    )
}

/// Creates test CardItems with solid-color images for previews.
private func previewCardItems() -> [CardItem] {
    let colors: [(UIColor, String, String)] = [
        (.systemRed, "Château Margaux 2015", "Bordeaux, France"),
        (.systemGreen, "Sauvignon Blanc", "Marlborough, NZ"),
        (.systemPurple, "Barolo Riserva", "Piedmont, Italy"),
    ]

    return colors.map { color, title, subtitle in
        let image = solidColorImage(color: color)
        return CardItem(
            photos: [
                CardPhoto(
                    cardSizeImageProvider: { image },
                    originalImageProvider: { image }
                )
            ],
            title: title,
            subtitle: subtitle,
            descriptionMarkdown: "",
            cardType: .regular
        )
    }
}

/// Creates a 300×400 solid-color UIImage for preview use.
private func solidColorImage(color: UIColor) -> UIImage {
    let size = CGSize(width: 300, height: 400)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
