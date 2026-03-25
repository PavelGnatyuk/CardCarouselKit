//
//  AsyncCardImageView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 25/03/2026.
//

import SwiftUI
import UIKit

/// Asynchronously loads and displays a card photo.
///
/// Uses a managed `.task` modifier that auto-cancels when the view disappears.
/// Shows a placeholder rectangle while the image is loading.
struct AsyncCardImageView: View {
    let photo: CardPhoto

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
            }
        }
        .task(id: photo.id) {
            image = await photo.cardSizeImageProvider()
        }
    }
}
