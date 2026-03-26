//
//  CardView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 26/03/2026.
//

import SwiftUI

/// Flip container combining front and back card faces with 3D Y-axis rotation.
///
/// The front face shows the photo (CardFrontView).
/// The back face shows the description (CardBackView).
/// Tap triggers `onTap` — the host decides whether to flip or handle differently.
struct CardView: View {
    let item: CardItem
    let isFlipped: Bool
    let isCentered: Bool
    let onTap: () -> Void
    var onPhotoIndexChanged: ((Int) -> Void)?
    var onPhotoDoubleTap: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CardFrontView(
                    item: item,
                    onPhotoIndexChanged: isCentered ? onPhotoIndexChanged : nil,
                    onPhotoDoubleTap: isCentered ? onPhotoDoubleTap : nil
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(isFlipped ? 0 : 1)
                .allowsHitTesting(!isFlipped)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

                CardBackView(item: item)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(isFlipped ? 1 : 0)
                    .allowsHitTesting(isFlipped)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
            }
        }
        .animation(.spring(duration: 0.6, bounce: 0.15), value: isFlipped)
        .onTapGesture {
            onTap()
        }
    }
}
