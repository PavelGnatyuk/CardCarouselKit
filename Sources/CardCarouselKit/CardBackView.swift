//
//  CardBackView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 26/03/2026.
//

import SwiftUI

/// Renders the back face of a carousel card — scrollable markdown description.
///
/// Domain-agnostic: knows nothing about wine.
/// Parent view controls dimensions — this view fills its proposed size.
public struct CardBackView: View {
    let item: CardItem

    public init(item: CardItem) {
        self.item = item
    }

    public var body: some View {
        Group {
            if item.descriptionMarkdown.isEmpty {
                emptyState
            } else {
                descriptionContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        .accessibilityElement(children: .combine)
    }

    private var descriptionContent: some View {
        ScrollView {
            markdownText
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var markdownText: some View {
        Group {
            if let attributed = try? AttributedString(markdown: item.descriptionMarkdown) {
                Text(attributed)
                    .font(.body)
                    .foregroundColor(.primary)
            } else {
                Text(item.descriptionMarkdown)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil.line")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(.gray)

            Text(String(localized: "Tap edit to add a description"))
                .font(.callout)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
