//
//  CardFrontView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 25/03/2026.
//

import SwiftUI

/// Renders the front face of a single carousel card.
///
/// Photo fills the entire card surface. Title and subtitle overlay the bottom
/// with a gradient for legibility — no separate text panel.
/// Parent view controls dimensions — this view fills its proposed size.
struct CardFrontView: View {
    let item: CardItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            photoArea
            textOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        .accessibilityElement(children: .combine)
    }

    private var photoArea: some View {
        Group {
            if let firstPhoto = item.photos.first {
                AsyncCardImageView(photo: firstPhoto)
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var textOverlay: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.subheadline)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
