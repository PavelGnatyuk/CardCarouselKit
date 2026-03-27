//
//  AsyncCardImageView.swift
//  CardCarouselKit
//
//  Created by Pavel Gnatyuk on 25/03/2026.
//

import SwiftUI
import UIKit

/// In-memory image cache shared across all card image views.
/// Survives LazyHStack view recycling so images don't reload from disk.
private nonisolated(unsafe) let imageCache = NSCache<NSString, UIImage>()

/// Asynchronously loads and displays a card photo.
///
/// On first load, fetches the image from disk and caches it.
/// On subsequent displays (after LazyHStack recycling), the cached image
/// is set in the initializer so it's available on the very first render frame —
/// no placeholder flash, no delayed resize.
struct AsyncCardImageView: View {
    let photo: CardPhoto
    let cardSize: CGSize

    @State private var image: UIImage?

    init(photo: CardPhoto, cardSize: CGSize) {
        self.photo = photo
        self.cardSize = cardSize
        let key = photo.id.uuidString as NSString
        _image = State(initialValue: imageCache.object(forKey: key))
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipped()
                    .transition(.identity)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .transition(.identity)
            }
        }
        .task(id: photo.id) {
            // Already have the image from cache (set in init)
            if image != nil { return }

            let loaded = await photo.cardSizeImageProvider()
            if let loaded {
                let key = photo.id.uuidString as NSString
                imageCache.setObject(loaded, forKey: key)
            }
            image = loaded
        }
    }
}
