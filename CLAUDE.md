# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bookmate** is a UIKit iPhone app for collecting and organizing meaningful sentences from books (맞춤형 독서 기록 및 공유 앱). Xcode 프로젝트와 Pencil 디자인 파일이 포함되어 있으며, 도서 선택 화면까지 구현된 상태.

## Repository Structure

```
Bookmate/
├── Bookmate/                          # Xcode 프로젝트
│   ├── Bookmate/
│   │   ├── AppDelegate.swift          # 앱 라이프사이클, Kingfisher 캐시 설정
│   │   ├── SceneDelegate.swift        # Scene 설정, 네비게이션 루트
│   │   ├── ViewController.swift       # HomeViewController (스텁)
│   │   ├── AppColor.swift             # 색상 팔레트 (Light + Dark)
│   │   ├── AppFont.swift              # 타이포그래피 (SF Pro, Nanum Myeongjo, Outfit)
│   │   ├── AppIcon.swift              # SF Symbol 매핑
│   │   ├── Models/
│   │   │   ├── RealmModels.swift      # Book, SearchedBook, Quote, Tag, CardStyle
│   │   │   └── BookSearchModels.swift # BookSearchResponse, BookItem (Naver API)
│   │   ├── Services/
│   │   │   └── NaverBookService.swift # Naver Books API 연동 (Alamofire)
│   │   ├── Repositories/
│   │   │   ├── BookRepository.swift   # Book/SearchedBook CRUD
│   │   │   └── QuoteRepository.swift  # Quote CRUD + 태그 관리
│   │   ├── Screens/
│   │   │   └── BookSelectionViewController.swift  # 도서 검색 + 최근 도서
│   │   ├── Font/                      # Nanum Myeongjo TTF 파일
│   │   └── Secrets.xcconfig           # Naver API 크레덴셜 (gitignore 대상)
│   └── Bookmate.xcodeproj/           # SPM 의존성
├── SampleRecognitionTExt/             # OCR 샘플 프로젝트 (SwiftUI, 참고용)
├── Bookmate.pen                       # Pencil 디자인 파일
├── images/                            # 스크린샷 및 디자인 미리보기
├── Functional_Specs.md                # 기능정의서
├── Design_Specs.md                    # 디자인정의서
├── BookAPI_specs.md                   # Naver Books API 명세
├── AppPlaning.md                      # 앱 기획 문서
└── Realm_Table_Scheme.md              # Realm DB 스키마
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
- Logo: **Outfit** 26px/700
- System UI (헤더, 본문, 캡션, 버튼, 태그): **SF Pro** (UIFont.systemFont)
- 공유 카드 인용문: **Nanum Myeongjo** 20px/400
- 공유 카드 큰따옴표: **Nanum Myeongjo ExtraBold** 56px
- 상태바 시간: **Inter** 16px/600
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

## Implementation Status

### 구현 완료
- **도서 선택 화면** (BookSelectionViewController) — Naver API 검색, 페이지네이션, 최근 검색 도서
- **Realm 모델** — Book, SearchedBook, Quote, Tag, CardStyle (스키마 v4)
- **Repository 계층** — BookRepository, QuoteRepository (전체 CRUD)
- **NaverBookService** — Alamofire 기반 API 연동
- **색상/폰트/아이콘 시스템** — AppColor, AppFont, AppIcon

### 미구현
- 홈 화면 (레이아웃만 완성, 데이터 바인딩 없음)
- 카메라/OCR 화면 (SampleRecognitionTExt에 참고 코드 있음)
- 사진 확인, 문장 선택, 카드 꾸미기, 공유, 문장 수집, 태그 추가 화면
- 내 문장 목록 화면
- 탭바 네비게이션 구조

### Navigation pattern
- tab bar (bottom) with modal flows for the capture → collect pipeline
- 현재는 BookSelectionViewController가 루트로 설정됨

## Code Rules

### Architecture & Patterns
- **UI Framework**: UIKit (SwiftUI only if absolutely necessary)
- **Architecture Pattern**: MVI (Model-View-Intent), or MVC if MVI is impractical
- **Constraint**: No Clean Architecture — keep structure simple and direct
- **File Organization**: Divide code into a few focused files (Screens, Services, Models, Repositories, Utils)

### Dependencies & Libraries
- **Networking**: Alamofire
- **UI Layout**: SnapKit
- **Reactive Programming**: RxSwift (RxCocoa for UIKit bindings)
- **Image Loading**: Kingfisher
- **Local Database**: Realm (RealmSwift)
- **User Preferences**: UserDefaults
- **Image Recognition**: Vision Framework (for OCR)
- **Book Data API**: Naver Books API (BookAPI_specs.md 참조, 구현 완료)
- **Package Manager**: Swift Package Manager (SPM)

### Code Style
- Keep implementations pragmatic and readable
- Prefer simple solutions over architectural perfection
- Use reactive patterns (RxSwift) for UI state management and event handling
