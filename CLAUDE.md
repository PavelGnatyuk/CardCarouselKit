# CLAUDE.md

## CardCarouselKit

Domain-agnostic card carousel Swift Package. Endless-loop horizontal paging with flip animation. **Knows nothing about wine** — all domain logic lives in the host app (VinoReel).

---

## Architecture

### Public API Surface

| Type | Role |
|------|------|
| `CardCarouselView` | Main carousel view — generic on `BackContent` for custom back face |
| `CardCarouselState` | `@Observable` shared state between carousel and host app |
| `CardCarouselDataSource` | Protocol — host app supplies cards and receives events |
| `CardItem` | Card data: photos, title, subtitle, markdown description, card type |
| `CardPhoto` | Async image provider with card-size and original-size closures |
| `CardType` | `.regular` (tap flips) or `.special` (tap triggers callback) |
| `CardBackView` | Default back face (scrollable markdown) — replaceable via `backContent` |
| `CardFramePreferenceKey` | Reports centered card frame to ancestor views for overlay positioning |

### Internal Types (do not expose)

| Type | Role |
|------|------|
| `CardCarouselLoop` | Builds virtual slot array for endless looping |
| `CardCarouselLayout` | Computes card dimensions from container size + size classes |
| `CardView` | Flip container with 3D Y-axis rotation |
| `CardFrontView` | Photo display with multi-photo navigation arrows |
| `AsyncCardImageView` | Async image loading with `NSCache` |
| `VirtualSlot` | Maps virtual scroll position to real card index |

---

## Key Design Decisions

### Endless Loop
Buffer of 2 slots on each side: `[last 2] + [all items] + [first 2]`. When scroll enters a buffer zone, repositions instantly (no animation) to the matching real slot. Requires ≥2 items; single-item carousel is non-looping.

### Image Caching
`AsyncCardImageView` uses a `nonisolated(unsafe)` module-level `NSCache<NSString, UIImage>` keyed by photo UUID. Cache is checked in `init` (not `.task`) so recycled views show images on the first render frame with no placeholder flash.

### Layout
`CardCarouselLayout` is purely computed from container size + size classes. No stored state, no GeometryReader of its own. Card aspect ratio is approximately 3:4. Layout adapts to iPhone portrait, iPhone landscape, iPad portrait, and iPad landscape.

### Card Dimensions
Card size is passed explicitly as `cardSize: CGSize` — never computed from GeometryReader inside CardView. This prevents frame fluctuation during scaleEffect animations.

### Nameplate Overlay
Title/subtitle rendering is **not** in CardCarouselKit. The host app uses `CardFramePreferenceKey` to position a nameplate overlay outside the package. This keeps the package domain-agnostic.

---

## Boundaries (do not violate)

- **No wine knowledge** — no wine models, no wine-specific strings, no wine UI
- **No SwiftData** — the package has no persistence
- **No network calls** — image loading is via closures provided by the host
- **No app-level dependencies** — no `@Environment` keys from the host app
- **UIKit only for `UIImage`** — no UIKit views or view controllers
