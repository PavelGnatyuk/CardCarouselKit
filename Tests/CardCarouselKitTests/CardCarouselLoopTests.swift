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

    /// Description: Verifies that two items produce the correct looping structure.
    /// Effective buffer is min(3, 2) = 2 for two items.
    ///
    /// Scenario:
    /// 1. Create two CardItems
    /// 2. Call build
    /// 3. Verify total count is 2 + 2 (leading) + 2 (trailing) = 6
    /// 4. Verify leading buffer contains the last 2 real items
    /// 5. Verify trailing buffer contains the first 2 real items
    @Test
    func buildFromTwoItems() {
        let items = makeCardItems(count: 2)
        let slots = CardCarouselLoop.build(from: items)

        // Effective buffer = min(3, 2) = 2
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
    /// Buffer size is 3 for 5 items.
    ///
    /// Scenario:
    /// 1. Create 5 CardItems
    /// 2. Call build
    /// 3. Verify total count is 3 + 5 + 3 = 11
    /// 4. Verify leading buffer has realIndices [2, 3, 4]
    /// 5. Verify real section has realIndices [0, 1, 2, 3, 4]
    /// 6. Verify trailing buffer has realIndices [0, 1, 2]
    @Test
    func buildFromFiveItems() {
        let items = makeCardItems(count: 5)
        let slots = CardCarouselLoop.build(from: items)

        #expect(slots.count == 11)

        // Leading buffer: last 3 items
        #expect(slots[0].realIndex == 2)
        #expect(slots[1].realIndex == 3)
        #expect(slots[2].realIndex == 4)

        // Real items: indices 0..4
        for i in 0..<5 {
            #expect(slots[3 + i].realIndex == i)
        }

        // Trailing buffer: first 3 items
        #expect(slots[8].realIndex == 0)
        #expect(slots[9].realIndex == 1)
        #expect(slots[10].realIndex == 2)
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

    /// Description: Verifies effectiveBuffer caps at item count.
    ///
    /// Scenario:
    /// 1. Verify effective buffer for 2 items is 2 (capped)
    /// 2. Verify effective buffer for 5 items is 3 (full buffer)
    @Test
    func effectiveBufferCapsAtItemCount() {
        #expect(CardCarouselLoop.effectiveBuffer(for: 2) == 2)
        #expect(CardCarouselLoop.effectiveBuffer(for: 3) == 3)
        #expect(CardCarouselLoop.effectiveBuffer(for: 5) == 3)
    }

    /// Description: Verifies firstRealIndex equals the effective buffer.
    ///
    /// Scenario:
    /// 1. Verify firstRealIndex is 3 for 5 items
    /// 2. Verify firstRealIndex is 2 for 2 items (capped)
    @Test
    func firstRealIndex() {
        #expect(CardCarouselLoop.firstRealIndex(itemCount: 5) == 3)
        #expect(CardCarouselLoop.firstRealIndex(itemCount: 2) == 2)
    }

    /// Description: Verifies leading buffer detection for indices below effective buffer.
    ///
    /// Scenario:
    /// 1. For 5 items (buffer=3): indices 0, 1, 2 are in buffer; 3 is not
    /// 2. For 2 items (buffer=2): indices 0, 1 are in buffer; 2 is not
    @Test
    func isInLeadingBuffer() {
        // 5 items → buffer = 3
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 0, itemCount: 5))
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 1, itemCount: 5))
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 2, itemCount: 5))
        #expect(!CardCarouselLoop.isInLeadingBuffer(virtualIndex: 3, itemCount: 5))

        // 2 items → buffer = 2
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 0, itemCount: 2))
        #expect(CardCarouselLoop.isInLeadingBuffer(virtualIndex: 1, itemCount: 2))
        #expect(!CardCarouselLoop.isInLeadingBuffer(virtualIndex: 2, itemCount: 2))
    }

    /// Description: Verifies trailing buffer detection for indices past real items.
    ///
    /// Scenario:
    /// 1. For 5 items (buffer=3), trailing starts at index 8 (3 + 5)
    /// 2. Check index 7 is not trailing, index 8 is trailing
    @Test
    func isInTrailingBuffer() {
        let itemCount = 5
        // Trailing starts at effectiveBuffer + itemCount = 3 + 5 = 8
        #expect(!CardCarouselLoop.isInTrailingBuffer(virtualIndex: 7, itemCount: itemCount))
        #expect(CardCarouselLoop.isInTrailingBuffer(virtualIndex: 8, itemCount: itemCount))
        #expect(CardCarouselLoop.isInTrailingBuffer(virtualIndex: 9, itemCount: itemCount))
        #expect(CardCarouselLoop.isInTrailingBuffer(virtualIndex: 10, itemCount: itemCount))
    }

    /// Description: Verifies matching real slot index for leading buffer positions.
    ///
    /// Scenario:
    /// 1. For 5 items (buffer=3):
    ///    - Leading index 0 → buffer + (5 - 3 + 0) = 3 + 2 = 5
    ///    - Leading index 1 → buffer + (5 - 3 + 1) = 3 + 3 = 6
    ///    - Leading index 2 → buffer + (5 - 3 + 2) = 3 + 4 = 7
    @Test
    func matchingRealSlotIndexForLeadingBuffer() {
        let itemCount = 5
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 0, itemCount: itemCount) == 5)
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 1, itemCount: itemCount) == 6)
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 2, itemCount: itemCount) == 7)
    }

    /// Description: Verifies matching real slot index for trailing buffer positions.
    ///
    /// Scenario:
    /// 1. For 5 items (buffer=3):
    ///    - Trailing index 8 → buffer + (8 - 3 - 5) = 3 + 0 = 3
    ///    - Trailing index 9 → buffer + (9 - 3 - 5) = 3 + 1 = 4
    ///    - Trailing index 10 → buffer + (10 - 3 - 5) = 3 + 2 = 5
    @Test
    func matchingRealSlotIndexForTrailingBuffer() {
        let itemCount = 5
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 8, itemCount: itemCount) == 3)
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 9, itemCount: itemCount) == 4)
        #expect(CardCarouselLoop.matchingRealSlotIndex(virtualIndex: 10, itemCount: itemCount) == 5)
    }
}
