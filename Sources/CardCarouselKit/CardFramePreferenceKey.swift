//
//  CardFramePreferenceKey.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 26/03/2026.
//

import SwiftUI

/// Reports the screen-space frame of the centered card to ancestor views.
public struct CardFramePreferenceKey: PreferenceKey {
    nonisolated public static let defaultValue: CGRect = .zero

    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}
