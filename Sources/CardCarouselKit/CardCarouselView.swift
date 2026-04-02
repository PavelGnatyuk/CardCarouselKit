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
///
/// Pass a `backContent` closure to customize the card back face.
/// When omitted, the default `CardBackView` (markdown description) is used.
public struct CardCarouselView<BackContent: View>: View {
    let state: CardCarouselState
    let dataSource: (any CardCarouselDataSource)?
    let items: [CardItem]
    let configuration: CardCarouselConfiguration
    @ViewBuilder let backContent: @MainActor (CardItem) -> BackContent

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var scrolledID: UUID?
    @State private var isRepositioning = false
    @State private var slots: [VirtualSlot] = []

    public init(
        state: CardCarouselState,
        dataSource: (any CardCarouselDataSource)? = nil,
        items: [CardItem] = [],
        configuration: CardCarouselConfiguration = .default,
        @ViewBuilder backContent: @escaping @MainActor (CardItem) -> BackContent
    ) {
        self.state = state
        self.dataSource = dataSource
        self.items = items
        self.configuration = configuration
        self.backContent = backContent
    }

    public var body: some View {
        GeometryReader { geometry in
            let layout = CardCarouselLayout(
                containerSize: geometry.size,
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass,
                configuration: configuration
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: layout.interCardSpacing) {
                    ForEach(slots) { slot in
                        let isCentered = slot.id == scrolledID
                            || (scrolledID == nil && slot.realIndex == 0)

                        CardView(
                            item: slot.item,
                            isFlipped: slot.item.cardType == .regular
                                && state.isFlipped(at: slot.realIndex),
                            isCentered: isCentered,
                            cardSize: CGSize(width: layout.cardWidth, height: layout.cardHeight),
                            onTap: { handleCardTap(slot) },
                            onPhotoIndexChanged: { photoIndex in
                                state.currentPhotoIndex = photoIndex
                            },
                            onPhotoDoubleTap: {
                                dataSource?.carouselDidTapPhoto(
                                    card: slot.item,
                                    photoIndex: state.currentPhotoIndex
                                )
                            },
                            backContent: { backContent(slot.item) }
                        )
                        .frame(width: layout.cardWidth, height: layout.cardHeight)
                        .opacity(isCentered ? 1.0 : configuration.sideCardOpacity)
                        .scaleEffect(isCentered ? 1.0 : (layout.isLandscape ? 1.0 : configuration.sideCardScale), anchor: .bottom)
                        .zIndex(isCentered ? 1 : 0)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(
                                        key: CardFramePreferenceKey.self,
                                        value: isCentered ? proxy.frame(in: .global) : .zero
                                    )
                            }
                        )
                        .animation(layout.isLandscape ? nil : .easeInOut(duration: 0.5), value: isCentered)
                        .id(slot.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .scrollPosition(id: $scrolledID)
            .contentMargins(.horizontal, layout.horizontalContentMargin, for: .scrollContent)
            .frame(height: layout.cardHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .onChange(of: items.map(\.id)) { _, _ in
            rebuildSlots()
        }
        .onChange(of: scrolledID) { _, newID in
            handleScrollChange(newID: newID)
        }
        .onAppear {
            rebuildSlots()
        }
    }

    // MARK: - Slots

    private func rebuildSlots() {
        slots = CardCarouselLoop.build(from: items)
        guard !slots.isEmpty else { return }

        // Resolve target: explicit request > preserve current > first card
        let targetID = state.pendingScrollTarget ?? state.centeredCard?.id
        state.pendingScrollTarget = nil

        let realStart = items.count >= 2 ? CardCarouselLoop.firstRealIndex(itemCount: items.count) : 0
        let realEnd = realStart + items.count

        let resolvedIndex: Int
        if let targetID,
           let match = (realStart..<realEnd).first(where: { slots[$0].item.id == targetID }) {
            resolvedIndex = match
        } else {
            resolvedIndex = realStart
        }

        scrolledID = slots[resolvedIndex].id
        state.centeredCard = slots[resolvedIndex].item
        state.currentPhotoIndex = 0
        state.currentCardIndex = slots[resolvedIndex].realIndex
    }

    // MARK: - Scroll Handling

    private func handleScrollChange(newID: UUID?) {
        guard let newID else { return }

        // After programmatic repositioning, just update state and reset flag
        if isRepositioning {
            isRepositioning = false
            if let slot = slots.first(where: { $0.id == newID }) {
                state.currentCardIndex = slot.realIndex
                state.centeredCard = slot.item
                state.currentPhotoIndex = 0
                state.resetFlipsOutsideWindow(center: slot.realIndex)
            }
            return
        }

        guard let virtualIndex = slots.firstIndex(where: { $0.id == newID }) else { return }
        let slot = slots[virtualIndex]

        // Check if we're in a buffer zone and need to reposition
        if items.count >= 2 {
            let needsReposition: Bool
            if CardCarouselLoop.isInLeadingBuffer(virtualIndex: virtualIndex, itemCount: items.count) {
                needsReposition = true
            } else if CardCarouselLoop.isInTrailingBuffer(virtualIndex: virtualIndex, itemCount: items.count) {
                needsReposition = true
            } else {
                needsReposition = false
            }

            if needsReposition {
                let targetIndex = CardCarouselLoop.matchingRealSlotIndex(
                    virtualIndex: virtualIndex,
                    itemCount: items.count
                )
                // Update state immediately so title shows correct card
                state.currentCardIndex = slot.realIndex
                state.centeredCard = slot.item
                state.currentPhotoIndex = 0
                // Yield one frame so the scroll gesture fully settles,
                // then jump scroll position instantly to the matching real slot.
                // The HStack keeps all views loaded, so the real slot's card
                // is already rendered at 0.6 opacity — the .animation modifier
                // smoothly transitions it to 1.0 like a normal scroll.
                isRepositioning = true
                Task {
                    await Task.yield()
                    withAnimation(.none) {
                        scrolledID = slots[targetIndex].id
                    }
                }
                return
            }
        }

        // Normal scroll — update state
        state.currentCardIndex = slot.realIndex
        state.centeredCard = slot.item
        state.currentPhotoIndex = 0
        state.resetFlipsOutsideWindow(center: slot.realIndex)
    }

    // MARK: - Card Tap

    private func handleCardTap(_ slot: VirtualSlot) {
        switch slot.item.cardType {
        case .special:
            dataSource?.carouselDidTapSpecialCard(slot.item)
        case .regular:
            withAnimation(.spring(duration: 0.6, bounce: 0.15)) {
                state.toggleFlip(at: slot.realIndex)
            }
        }
    }
}

// MARK: - Default Back Face Convenience Init

extension CardCarouselView where BackContent == CardBackView {
    /// Creates a carousel with the default back face (markdown description).
    public init(
        state: CardCarouselState,
        dataSource: (any CardCarouselDataSource)? = nil,
        items: [CardItem] = [],
        configuration: CardCarouselConfiguration = .default
    ) {
        self.state = state
        self.dataSource = dataSource
        self.items = items
        self.configuration = configuration
        self.backContent = { item in CardBackView(item: item) }
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
