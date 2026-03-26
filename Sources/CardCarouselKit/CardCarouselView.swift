//
//  CardCarouselView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import SwiftUI

/// The main carousel view. Displays cards in a paging horizontal scroll.
///
/// Each card is centered within a full-width page. Neighboring cards peek
/// in the margins. Swipe snaps one card at a time.
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

            VStack(spacing: 16) {
                cardTitle
                    .frame(height: 60, alignment: .bottom)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: layout.interCardSpacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            let isCentered = item.id == scrolledID || (scrolledID == nil && index == 0)

                            CardView(
                                item: item,
                                isFlipped: item.cardType == .regular && state.isFlipped(at: index),
                                isCentered: isCentered,
                                onTap: { handleCardTap(item, at: index) },
                                onPhotoIndexChanged: { photoIndex in
                                    state.currentPhotoIndex = photoIndex
                                }
                            )
                            .frame(width: layout.cardWidth, height: layout.cardHeight)
                            .clipped()
                            .opacity(isCentered ? 1.0 : 0.5)
                            .scaleEffect(isCentered ? 1.0 : 0.92)
                            .blur(radius: isCentered ? 0 : 2)
                            .offset(y: isCentered ? 0 : 8)
                            .zIndex(isCentered ? 1 : 0)
                            .animation(.easeInOut(duration: 0.25), value: scrolledID)
                            .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledID)
                .contentMargins(.horizontal, layout.horizontalContentMargin, for: .scrollContent)
                .frame(height: layout.cardHeight)
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onChange(of: scrolledID) { _, newID in
            guard let newID else { return }
            if let index = items.firstIndex(where: { $0.id == newID }) {
                state.currentCardIndex = index
                state.centeredCard = items[index]
                state.resetFlipsOutsideWindow(center: index)
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

    private var centeredItem: CardItem? {
        if let scrolledID {
            return items.first { $0.id == scrolledID }
        }
        return items.first
    }

    private var cardTitle: some View {
        VStack(spacing: 2) {
            if let item = centeredItem, item.cardType == .regular {
                Text(item.title)
                    .font(.title.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if !item.subtitle.isEmpty {
                    Text(item.subtitle)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.25), value: scrolledID)
    }

    private func handleCardTap(_ item: CardItem, at index: Int) {
        switch item.cardType {
        case .special:
            dataSource?.carouselDidTapSpecialCard(item)
        case .regular:
            state.toggleFlip(at: index)
        }
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
