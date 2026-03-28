// Created by Pavel Gnatyuk

import Testing
@testable import CardCarouselKit

@Suite("CardCarouselLoop -- Build Slots", .tags(.pureLogic))
struct CardCarouselLoopBuildTests {

    /// Description: Verifies that building from an empty array produces no slots.
    ///
    /// Scenario:
    /// 1. Call build with an empty items array
    /// 2. Verify the result is empty
    @Test
    func buildFromEmptyItems() {
        let slots = CardCarouselLoop.build(from: [])
        #expect(slots.isEmpty)
    }

    /// Description: Verifies that a single item produces one slot with no buffer.
    ///
    /// Scenario:
    /// 1. Create one CardItem
    /// 2. Call build with the single-item array
    /// 3. Verify exactly one slot is returned
    /// 4. Verify the slot's realIndex is 0
    @Test
    func buildFromSingleItem() {
        let items = makeCardItems(count: 1)
        let slots = CardCarouselLoop.build(from: items)

        #expect(slots.count == 1)
        #expect(slots[0].realIndex == 0)
        #expect(slots[0].item.id == items[0].id)
    }

    /// Description: Verifies that two items produce the correct looping structure with buffers.
    ///
    /// Scenario:
    /// 1. Create two CardItems
    /// 2. Call build
    /// 3. Verify total count is 2 + 2 (leading buffer) + 2 (trailing buffer) = 6
    /// 4. Verify leading buffer contains the last 2 real items
    /// 5. Verify trailing buffer contains the first 2 real items
    @Test
    func buildFromTwoItems() {
        let items = makeCardItems(count: 2)
        let slots = CardCarouselLoop.build(from: items)

        // [last2] + [all2] + [first2] = 6
        #expect(slots.count == 6)

        // Leading buffer: items[0], items[1] (last 2 of a 2-item array)
        #expect(slots[0].realIndex == 0)
        #expect(slots[1].realIndex == 1)

        // Real items
        #expect(slots[2].realIndex == 0)
        #expect(slots[3].realIndex == 1)

        // Trailing buffer
        #expect(slots[4].realIndex == 0)
        #expect(slots[5].realIndex == 1)
    }

    /// Description: Verifies correct slot structure for a typical 5-item carousel.
    ///
    /// Scenario:
    /// 1. Create 5 CardItems
    /// 2. Call build
    /// 3. Verify total count is 5 + 2 + 2 = 9
    /// 4. Verify leading buffer has realIndices [3, 4]
    /// 5. Verify real section has realIndices [0, 1, 2, 3, 4]
    /// 6. Verify trailing buffer has realIndices [0, 1]
    @Test
    func buildFromFiveItems() {
        let items = makeCardItems(count: 5)
        let slots = CardCarouselLoop.build(from: items)

        #expect(slots.count == 9)

        // Leading buffer: last 2 items
        #expect(slots[0].realIndex == 3)
        #expect(slots[1].realIndex == 4)

        // Real items: indices 0..4
        for i in 0..<5 {
            #expect(slots[2 + i].realIndex == i)
        }

        // Trailing buffer: first 2 items
        #expect(slots[7].realIndex == 0)
        #expect(slots[8].realIndex == 1)
    }

    /// Description: Verifies that each slot gets a unique UUID even when mapping to the same real item.
    ///
    /// Scenario:
    /// 1. Create 3 CardItems
    /// 2. Call build
    /// 3. Collect all slot IDs
    /// 4. Verify all IDs are unique
    @Test
    func allSlotIDsAreUnique() {
        let items = makeCardItems(count: 3)
        let slots = CardCarouselLoop.build(from: items)

        let ids = slots.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    /// Description: Verifies that slots reference the original CardItem instances by ID.
    ///
    /// Scenario:
    /// 1. Create 3 CardItems
    /// 2. Call build
    /// 3. Verify each slot's item.id matches the original item at realIndex
    @Test
    func slotsReferenceOriginalItems() {
        let items = makeCardItems(count: 3)
        let slots = CardCarouselLoop.build(from: items)

        for slot in slots {
            #expect(slot.item.id == items[slot.realIndex].id)
        }
    }
}

@Suite("CardCarouselLoop -- Buffer Detection", .tags(.pureLogic))
struct CardCarouselLoopBufferTests {

    /// Description: Verifies that firstRealIndex equals the buffer size.
    ///
    /// Scenario:
    /// 1. Read firstRealIndex
    /// 2. Verify it equals bufferSize (2)
    @Test
    func firstRealIndex() {
        #expect(CardCarouselLoop.firstRealIndex == CardCarouselLoop.bufferSize)
        #expect(CardCarouselLoop.firstRealIndex == 2)
    }

    /// Description: Verifies leading buffer detection for indices below bufferSize.
    ///
    /// Scenario:
    /// 1. Check indices 0 and 1 are in the leading buffer
    /// 2. Check index 2 is not in the leading buffer
    @Test
    func isInLeadingBuffer() {
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 0))
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 1))
        #expect(!CardCarouselLoop.isInLeadingBuffer(virtualIndex: 2))
        #expect(!CardCarouselLoop.isInLeadingBuffer(virtualIndex: 5))
    }

    /// Description: Verifies trailing buffer detection for indices past real items.
    ///
    /// Scenario:
    /// 1. For 5 items, trailing starts at index 7 (bufferSize + itemCount)
    /// 2. Check index 6 is not trailing
    /// 3. Check index 7 is trailing
    /// 4. Check index 8 is trailing
    @Test
    func isInTrailingBuffer() {
        let itemCount = 5
        // Trailing starts at bufferSize + itemCount = 7
        #expect(!CardCarouselLoop.isInTrailingBuffer(virtualIndex: 6, itemCount: itemCount))
        #expect(CardCarouselLoop.isInTrailingBuffer(virtualIndex: 7, itemCount: itemCount))
        #expect(CardCarouselLoop.isInTrailingBuffer(virtualIndex: 8, itemCount: itemCount))
    }

    /// Description: Verifies matching real slot index for leading buffer positions.
    ///
    /// Scenario:
    /// 1. For 5 items, leading buffer index 0 maps to real slot for item[3] at virtual index 5
    /// 2. Leading buffer index 1 maps to real slot for item[4] at virtual index 6
    @Test
    func matchingRealSlotIndexForLeadingBuffer() {
        let itemCount = 5
        // Leading index 0 → bufferSize + (itemCount - bufferSize + 0) = 2 + 3 = 5
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 0, itemCount: itemCount) == 5)
        // Leading index 1 → bufferSize + (itemCount - bufferSize + 1) = 2 + 4 = 6
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 1, itemCount: itemCount) == 6)
    }

    /// Description: Verifies matching real slot index for trailing buffer positions.
    ///
    /// Scenario:
    /// 1. For 5 items, trailing buffer index 7 maps to real slot for item[0] at virtual index 2
    /// 2. Trailing buffer index 8 maps to real slot for item[1] at virtual index 3
    @Test
    func matchingRealSlotIndexForTrailingBuffer() {
        let itemCount = 5
        // Trailing index 7 → bufferSize + (7 - bufferSize - itemCount) = 2 + 0 = 2
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 7, itemCount: itemCount) == 2)
        // Trailing index 8 → bufferSize + (8 - bufferSize - itemCount) = 2 + 1 = 3
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 8, itemCount: itemCount) == 3)
    }
}
