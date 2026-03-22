//
//  CardCarouselView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 22/03/2026.
//

import SwiftUI

/// The main carousel view. Displays cards in a horizontally scrollable endless-loop layout.
public struct CardCarouselView: View {
    let state: CardCarouselState
    let dataSource: (any CardCarouselDataSource)?
    let items: [CardItem]

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
        VStack {
            Text("CardCarouselView")
                .font(.title2)
            Text("\(items.count) cards")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
