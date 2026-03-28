// Created by Pavel Gnatyuk

import Testing
@testable import CardCarouselKit

@MainActor
@Suite("CardCarouselState -- Flip State", .tags(.pureLogic))
struct CardCarouselStateFlipTests {

    /// Description: Verifies that a new state has no flipped positions.
    ///
    /// Scenario:
    /// 1. Create a new CardCarouselState
    /// 2. Check isFlipped for position 0
    /// 3. Verify it returns false
    @Test
    func initiallyNotFlipped() {
        let state = CardCarouselState()
        #expect(!state.isFlipped(at: 0))
        #expect(!state.isFlipped(at: 5))
    }

    /// Description: Verifies toggleFlip flips a position on then off.
    ///
    /// Scenario:
    /// 1. Create a new state
    /// 2. Toggle position 2
    /// 3. Verify position 2 is flipped
    /// 4. Toggle position 2 again
    /// 5. Verify position 2 is no longer flipped
    @Test
    func toggleFlipOnAndOff() {
        let state = CardCarouselState()

        state.toggleFlip(at: 2)
        #expect(state.isFlipped(at: 2))

        state.toggleFlip(at: 2)
        #expect(!state.isFlipped(at: 2))
    }

    /// Description: Verifies that flipping one position does not affect others.
    ///
    /// Scenario:
    /// 1. Create a new state
    /// 2. Toggle positions 1 and 3
    /// 3. Verify positions 1 and 3 are flipped
    /// 4. Verify positions 0, 2, 4 are not flipped
    @Test
    func flippingIsIndependent() {
        let state = CardCarouselState()

        state.toggleFlip(at: 1)
        state.toggleFlip(at: 3)

        #expect(state.isFlipped(at: 1))
        #expect(!state.isFlipped(at: 2))
        #expect(state.isFlipped(at: 3))
        #expect(!state.isFlipped(at: 4))
    }

    /// Description: Verifies resetFlip removes a specific flipped position.
    ///
    /// Scenario:
    /// 1. Create a new state and flip positions 1 and 2
    /// 2. Reset position 1
    /// 3. Verify position 1 is no longer flipped
    /// 4. Verify position 2 is still flipped
    @Test
    func resetFlipRemovesSpecificPosition() {
        let state = CardCarouselState()

        state.toggleFlip(at: 1)
        state.toggleFlip(at: 2)
        state.resetFlip(at: 1)

        #expect(!state.isFlipped(at: 1))
        #expect(state.isFlipped(at: 2))
    }

    /// Description: Verifies resetFlip on an unflipped position is a no-op.
    ///
    /// Scenario:
    /// 1. Create a new state
    /// 2. Reset position 0 (never flipped)
    /// 3. Verify no crash and position is still not flipped
    @Test
    func resetFlipOnUnflippedIsNoOp() {
        let state = CardCarouselState()
        state.resetFlip(at: 0)
        #expect(!state.isFlipped(at: 0))
    }
}

@MainActor
@Suite("CardCarouselState -- Reset Outside Window", .tags(.pureLogic))
struct CardCarouselStateWindowTests {

    /// Description: Verifies that flips outside the visible window are reset.
    ///
    /// Scenario:
    /// 1. Create a state and flip positions 0, 3, 5, 8
    /// 2. Call resetFlipsOutsideWindow with center 5, windowSize 1
    /// 3. Verify only positions 4, 5, 6 are retained (5 ± 1)
    /// 4. Positions 0, 3, 8 should be reset
    @Test
    func resetsFlipsOutsideWindow() {
        let state = CardCarouselState()

        state.toggleFlip(at: 0)
        state.toggleFlip(at: 3)
        state.toggleFlip(at: 5)
        state.toggleFlip(at: 8)

        state.resetFlipsOutsideWindow(center: 5, windowSize: 1)

        #expect(!state.isFlipped(at: 0))
        #expect(!state.isFlipped(at: 3))
        #expect(state.isFlipped(at: 5))
        #expect(!state.isFlipped(at: 8))
    }

    /// Description: Verifies default windowSize of 1 keeps center ± 1.
    ///
    /// Scenario:
    /// 1. Flip positions 2, 3, 4, 5
    /// 2. Call resetFlipsOutsideWindow with center 3 (default windowSize=1)
    /// 3. Verify positions 2, 3, 4 are kept, position 5 is reset
    @Test
    func defaultWindowSizeIsOne() {
        let state = CardCarouselState()

        state.toggleFlip(at: 2)
        state.toggleFlip(at: 3)
        state.toggleFlip(at: 4)
        state.toggleFlip(at: 5)

        state.resetFlipsOutsideWindow(center: 3)

        #expect(state.isFlipped(at: 2))
        #expect(state.isFlipped(at: 3))
        #expect(state.isFlipped(at: 4))
        #expect(!state.isFlipped(at: 5))
    }

    /// Description: Verifies that a larger window keeps more positions.
    ///
    /// Scenario:
    /// 1. Flip positions 0 through 6
    /// 2. Call resetFlipsOutsideWindow with center 3, windowSize 2
    /// 3. Verify positions 1-5 are kept (3 ± 2)
    /// 4. Verify positions 0 and 6 are reset
    @Test
    func largerWindowKeepsMorePositions() {
        let state = CardCarouselState()

        for i in 0...6 {
            state.toggleFlip(at: i)
        }

        state.resetFlipsOutsideWindow(center: 3, windowSize: 2)

        #expect(!state.isFlipped(at: 0))
        #expect(state.isFlipped(at: 1))
        #expect(state.isFlipped(at: 2))
        #expect(state.isFlipped(at: 3))
        #expect(state.isFlipped(at: 4))
        #expect(state.isFlipped(at: 5))
        #expect(!state.isFlipped(at: 6))
    }

    /// Description: Verifies resetFlipsOutsideWindow with no flipped positions is a no-op.
    ///
    /// Scenario:
    /// 1. Create a fresh state with no flips
    /// 2. Call resetFlipsOutsideWindow
    /// 3. Verify no crash and all positions remain unflipped
    @Test
    func resetWithNoFlipsIsNoOp() {
        let state = CardCarouselState()
        state.resetFlipsOutsideWindow(center: 0)
        #expect(!state.isFlipped(at: 0))
    }
}
