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
struct CardBackView: View {
    let item: CardItem

    var body: some View {
        ZStack {
            if item.descriptionMarkdown.isEmpty {
                emptyState
            } else {
                descriptionContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
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
            } else {
                Text(item.descriptionMarkdown)
                    .font(.body)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.alignleft")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text(String(localized: "No description yet"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
