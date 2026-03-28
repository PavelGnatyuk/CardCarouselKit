//
//  CardCarouselLoop.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 26/03/2026.
//

import Foundation

/// A virtual slot in the endless carousel. Maps to a real item by index.
///
/// Each slot has a unique `id` for scroll position tracking,
/// but references the original `CardItem` to preserve photo IDs and avoid image reloads.
struct VirtualSlot: Identifiable {
    let id: UUID
    let realIndex: Int
    let item: CardItem
}

/// Builds the virtual slot array for an endless-loop carousel.
///
/// Given N real items, produces: `[last buffer items] + [all items] + [first buffer items]`.
/// For 0 or 1 items, returns a plain (non-looping) slot array.
///
/// Buffer size is capped at `items.count` so that 2-item carousels still loop
/// with an effective buffer of 2.
enum CardCarouselLoop {
    static let bufferSize = 3

    /// Effective buffer size, capped to the item count.
    static func effectiveBuffer(for itemCount: Int) -> Int {
        min(bufferSize, itemCount)
    }

    /// Builds the virtual slots array from real items.
    static func build(from items: [CardItem]) -> [VirtualSlot] {
        guard items.count >= 2 else {
            return items.enumerated().map { index, item in
                VirtualSlot(id: UUID(), realIndex: index, item: item)
            }
        }

        let buffer = effectiveBuffer(for: items.count)
        var slots: [VirtualSlot] = []

        // Leading buffer: last `buffer` items
        for i in (items.count - buffer)..<items.count {
            slots.append(VirtualSlot(id: UUID(), realIndex: i, item: items[i]))
        }

        // Real items
        for i in 0..<items.count {
            slots.append(VirtualSlot(id: UUID(), realIndex: i, item: items[i]))
        }

        // Trailing buffer: first `buffer` items
        for i in 0..<buffer {
            slots.append(VirtualSlot(id: UUID(), realIndex: i, item: items[i]))
        }

        return slots
    }

    /// Index of the first real item in the virtual slots array.
    static func firstRealIndex(itemCount: Int) -> Int {
        effectiveBuffer(for: itemCount)
    }

    /// Whether a virtual index is in the leading buffer zone.
    static func isInLeadingBuffer(virtualIndex: Int, itemCount: Int) -> Bool {
        virtualIndex < effectiveBuffer(for: itemCount)
    }

    /// Whether a virtual index is in the trailing buffer zone.
    static func isInTrailingBuffer(virtualIndex: Int, itemCount: Int) -> Bool {
        virtualIndex >= effectiveBuffer(for: itemCount) + itemCount
    }

    /// The virtual index of the matching real slot for a buffer slot.
    static func matchingRealSlotIndex(virtualIndex: Int, itemCount: Int) -> Int {
        let buffer = effectiveBuffer(for: itemCount)
        if virtualIndex < buffer {
            // Leading buffer → jump to the real slot
            return buffer + (itemCount - buffer + virtualIndex)
        } else {
            // Trailing buffer → jump to the real slot
            return buffer + (virtualIndex - buffer - itemCount)
        }
    }
}
