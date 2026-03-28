//
//  CardView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 26/03/2026.
//

import SwiftUI

/// Flip container combining front and back card faces with 3D Y-axis rotation.
///
/// The front face shows the photo (CardFrontView).
/// The back face is provided by `backContent` — defaults to `CardBackView`.
/// Tap triggers `onTap` — the host decides whether to flip or handle differently.
///
/// Card dimensions are passed explicitly as `cardSize` — never computed from
/// GeometryReader — so the photo frame is fixed and cannot fluctuate during
/// scaleEffect animation.
struct CardView<BackContent: View>: View {
    let item: CardItem
    let isFlipped: Bool
    let isCentered: Bool
    let cardSize: CGSize
    let onTap: () -> Void
    var onPhotoIndexChanged: ((Int) -> Void)?
    var onPhotoDoubleTap: (() -> Void)?
    @ViewBuilder let backContent: () -> BackContent

    var body: some View {
        ZStack {
            CardFrontView(
                item: item,
                cardSize: cardSize,
                onPhotoIndexChanged: isCentered ? onPhotoIndexChanged : nil,
                onPhotoDoubleTap: isCentered ? onPhotoDoubleTap : nil
            )
            .frame(width: cardSize.width, height: cardSize.height)
            .opacity(isFlipped ? 0 : 1)
            .allowsHitTesting(!isFlipped)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            backContent()
                .frame(width: cardSize.width, height: cardSize.height)
                .opacity(isFlipped ? 1 : 0)
                .allowsHitTesting(isFlipped)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview("Card — Front Face") {
    CardView(
        item: previewCardItem(color: .systemRed, title: "Front", subtitle: "Tap to flip"),
        isFlipped: false,
        isCentered: true,
        cardSize: CGSize(width: 260, height: 360),
        onTap: {},
        backContent: { CardBackView(item: previewCardItem(color: .systemRed, title: "Front", subtitle: "Tap to flip")) }
    )
    .frame(width: 260, height: 360)
    .padding()
}

#Preview("Card — Back Face") {
    CardView(
        item: previewCardItem(
            color: .systemBlue,
            title: "Flipped",
            subtitle: "Back side",
            descriptionMarkdown: "**Sample** markdown content with *formatting*."
        ),
        isFlipped: true,
        isCentered: true,
        cardSize: CGSize(width: 260, height: 360),
        onTap: {},
        backContent: {
            CardBackView(item: previewCardItem(
                color: .systemBlue,
                title: "Flipped",
                subtitle: "Back side",
                descriptionMarkdown: "**Sample** markdown content with *formatting*."
            ))
        }
    )
    .frame(width: 260, height: 360)
    .padding()
}
