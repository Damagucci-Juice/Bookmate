# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bookmate** is a UIKit iPhone app for collecting and organizing meaningful sentences from books (맞춤형 독서 기록 및 공유 앱). The repository currently contains a Pencil design file (`Bookmate.pen`) with complete app screens and reference images — no Swift source code yet.

## Repository Structure

```
Bookmate/
├── Bookmate.pen      # Pencil design file (all screens, color variables, layouts)
└── images/           # Reference screenshots and generated design previews
```

## Working with the Design File

The `.pen` file is **encrypted** and can only be read/modified via the Pencil MCP tools (`mcp__pencil__*`). Do **not** use `Read`, `Grep`, or `cat` on `.pen` files.

Key Pencil tools:
- `get_editor_state` — identify the active file and selection
- `batch_get` — read nodes and structure
- `batch_design` — insert/update/delete nodes
- `get_screenshot` — visual validation
- `get_variables` / `set_variables` — manage color/theme variables

## Design System

### Color Variables (semantic naming, light/dark theme support)

| Variable | Light | Dark |
|---|---|---|
| `accent` | `#3D8A5A` (forest green) | `df-accent` same |
| `accent-light` | `#C8F0D8` (mint) | `df-highlight` `#7FB685` |
| `bg` | `#F5F4F1` (off-white) | `df-bg` `#121412` |
| `card` | `#FFFFFF` | `df-card` `#2D302D` |
| `coral` | `#D89575` | — |
| `border` | `#E5E4E1` | `df-border` `#3E423E` |
| `text-primary` | `#1A1918` | `df-text-primary` `#E9ECEF` |
| `text-secondary` | `#6D6C6A` | `df-text-secondary` `#ADB5BD` |
| `text-tertiary` | `#9C9B99` | — |
| `tab-inactive` | `#A8A7A5` | — |

### Typography
- Logo/headlines: **Outfit** 26px/700
- Body: **Inter** 16px/600
- Text hierarchy via `text-primary` → `text-secondary` → `text-tertiary`

### Layout Conventions
- Card corner radius: **20px**
- Card shadow: `rgba(26,25,24,0.05)`, blur 12px, offset (0, 2)
- Flexbox (vertical/horizontal) with consistent padding and gap spacing

## App Screens & User Flow

13 primary screens covering a linear capture → organize → view workflow:

```
1 홈 (Home)
  → 2 도서 선택 (Book Selection)
    → 3-1 사진 촬영 (Camera Capture)
      → 3-2 사진 확인 (Photo Review)
        → 3-3 텍스트 인식 (OCR / Text Recognition)
          → 4 문장 선택 (Sentence Selection)
            → 5 카드 꾸미기 (Card Customization)
              ├─ 5-1-2 (Photo Background variant)
              └─ 5-2 공유 시트 (Share Sheet)
            → 6 문장 수집 (Collection Save)
              └─ 6-2 태그 추가 (Add Tags)
            → 7 내 문장 (My Sentences)
              └─ 7-2 태그 필터 (Tag Filter)
```

Screen node IDs: `a3p4g` (Home), `KjHwV` (Book Selection), `p67S4` (Camera), `Qd8np` (Photo Review), `VRu1h` (OCR), `ZZQXo` (Sentence Select), `v8DT8` (Card Customize), `xGLFA` (Share), `jz2Vy` (Photo BG variant), `nzcgh` (Collection), `HHG5a` (Tags), `jeZEu` (My Sentences), `EfqHN` (Tag Filter).

## Implementation Notes (when building the iOS app)

Key iOS frameworks needed:
- **Vision / VisionKit** — OCR text recognition from photos
- **AVFoundation** — camera capture
- **UIKit** — all UI (no SwiftUI based on project intent)
- **RealmSwift** — Persisting collected sentences and tags

Navigation pattern: tab bar (bottom) with modal flows for the capture → collect pipeline.

## Code Rules

### Architecture & Patterns
- **UI Framework**: UIKit (SwiftUI only if absolutely necessary)
- **Architecture Pattern**: MVI (Model-View-Intent), or MVC if MVI is impractical
- **Constraint**: No Clean Architecture — keep structure simple and direct
- **File Organization**: Divide code into a few focused files (Screens, Services, Models, Utils)

### Dependencies & Libraries
- **Networking**: Alamofire
- **UI Layout**: SnapKit
- **Reactive Programming**: RxSwift (RxCocoa for UIKit bindings)
- **Image Loading**: Kingfisher
- **Local Database**: Realm (RealmSwift)
- **User Preferences**: UserDefaults
- **Image Recognition**: Vision Framework (for OCR)
- **Book Data API**: Naver Books API (documentation TBD)

### Code Style
- Keep implementations pragmatic and readable
- Prefer simple solutions over architectural perfection
- Use reactive patterns (RxSwift) for UI state management and event handling
