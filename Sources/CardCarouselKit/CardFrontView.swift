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
/// Supports multi-photo navigation with left/right arrow overlays.
/// Parent view controls dimensions — this view fills its proposed size.
struct CardFrontView: View {
    let item: CardItem
    var onPhotoIndexChanged: ((Int) -> Void)?
    var onPhotoDoubleTap: (() -> Void)?

    @State private var currentPhotoIndex: Int = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            photoArea
            if item.cardType == .regular {
                nameplate
            }
            if hasMultiplePhotos {
                photoNavigationArrows
                photoCounter
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        .accessibilityElement(children: .combine)
        .onChange(of: item.id) { _, _ in
            currentPhotoIndex = 0
            onPhotoIndexChanged?(0)
        }
        .onChange(of: currentPhotoIndex) { _, newIndex in
            onPhotoIndexChanged?(newIndex)
        }
    }

    // MARK: - Photo Area

    private var photoArea: some View {
        Group {
            if let photo = currentPhoto {
                AsyncCardImageView(photo: photo)
                    .id(photo.id)
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onTapGesture(count: 2) {
            onPhotoDoubleTap?()
        }
    }

    // MARK: - Navigation Arrows

    private var photoNavigationArrows: some View {
        HStack {
            arrowButton(direction: .left)
            Spacer()
            arrowButton(direction: .right)
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 50)
    }

    private func arrowButton(direction: ArrowDirection) -> some View {
        let isEnabled = direction == .left ? currentPhotoIndex > 0 : currentPhotoIndex < item.photos.count - 1

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if direction == .left {
                    currentPhotoIndex = max(0, currentPhotoIndex - 1)
                } else {
                    currentPhotoIndex = min(item.photos.count - 1, currentPhotoIndex + 1)
                }
            }
        } label: {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.black.opacity(0.35), in: Circle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1.0 : 0.3)
        .disabled(!isEnabled)
        .accessibilityLabel(direction == .left
            ? String(localized: "Previous photo")
            : String(localized: "Next photo")
        )
    }

    // MARK: - Photo Counter

    private var photoCounter: some View {
        Text("\(currentPhotoIndex + 1) / \(item.photos.count)")
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.black.opacity(0.3), in: Capsule())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(8)
    }

    // MARK: - Nameplate

    private var nameplate: some View {
        VStack(spacing: 2) {
            Text(item.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var hasMultiplePhotos: Bool {
        item.photos.count > 1
    }

    private var currentPhoto: CardPhoto? {
        guard !item.photos.isEmpty else { return nil }
        let safeIndex = min(currentPhotoIndex, item.photos.count - 1)
        return item.photos[safeIndex]
    }

    private enum ArrowDirection {
        case left, right
    }
}
