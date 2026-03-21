# Bookmate — 디자인 정의서 (Design Specification)

> Atomic Design System 기반 UI 컴포넌트 계층 구조 및 시각 사양 문서

---

## 1. 문서 개요

| 항목 | 내용 |
|---|---|
| 프로젝트명 | Bookmate |
| 문서 버전 | 1.0 |
| 작성일 | 2026-03-20 |
| 대상 플랫폼 | iOS (iPhone) |
| 기준 해상도 | 390 × 844 pt (iPhone 14) |
| 디자인 방법론 | Atomic Design (Atoms → Molecules → Organisms → Templates) |
| 디자인 소스 | `Bookmate.pen` (Node ID: `xHavm`) |

---

## 2. Atoms — 기본 요소

> 더 이상 분해할 수 없는 가장 작은 UI 단위. 색상, 타이포그래피, 아이콘, 스페이싱 등 디자인의 기초를 구성합니다.

---

### 2.1 Colors — Light Theme

| 변수명 | HEX | 용도 |
|---|---|---|
| `$bg` | `#F5F4F1` | 앱 배경색 (off-white) |
| `$card` | `#FFFFFF` | 카드/컨테이너 배경 |
| `$accent` | `#3D8A5A` | 주 액센트 (forest green) — 버튼, 선택 상태, FAB, 탭 활성 |
| `$accent-light` | `#C8F0D8` | 액센트 보조 (mint) — 태그 배경 |
| `$coral` | `#D89575` | 보조 색상 — 큰따옴표 아이콘, 강조 |
| `$text-primary` | `#1A1918` | 주 텍스트 |
| `$text-secondary` | `#6D6C6A` | 보조 텍스트 |
| `$text-tertiary` | `#9C9B99` | 3차 텍스트 (메타 정보) |
| `$border` | `#E5E4E1` | 테두리, 구분선 |
| `$tab-inactive` | `#A8A7A5` | 탭바 비활성 아이콘/텍스트 |

### 2.2 Colors — Deep Focus Theme (Dark)

| 변수명 | HEX | 용도 |
|---|---|---|
| `$df-bg` | `#121412` | 앱 배경 |
| `$df-surface` | `#1A1C1A` | 서피스 (탭바 pill 배경 등) |
| `$df-card` | `#2D302D` | 카드 배경 |
| `$df-border` | `#3E423E` | 테두리, 구분선 |
| `$df-highlight` | `#7FB685` | 하이라이트 (accent-light 대체) |
| `$df-accent` | `#3D8A5A` | 액센트 (Light와 동일) |
| `$df-text-primary` | `#E9ECEF` | 주 텍스트 |
| `$df-text-secondary` | `#ADB5BD` | 보조 텍스트 |
| `$df-text-on-accent` | `#FAFAFA` | 액센트 배경 위 텍스트 |

---

### 2.3 Typography

#### 폰트 패밀리

| 폰트 | 타입 | 용도 |
|---|---|---|
| **SF Pro (System)** | Sans-serif (시스템 폰트) | 시스템 UI 전반 — 헤더, 본문, 캡션, 버튼, 태그 등 |
| **Nanum Myeongjo (나눔명조)** | Serif (명조체) | 공유 카드 인용문 — 문학적/감성적 표현 |
| **Outfit** | Sans-serif | 브랜드 로고 ("Bookmate") 전용 |
| **Inter** | Sans-serif | 시간 표시, 숫자/기술 텍스트 |

> **디자인 원칙:** Serif (Nanum Myeongjo) vs Sans-serif (SF Pro) 대비를 통해 "콘텐츠(인용문)"와 "크롬(UI)"을 시각적으로 명확히 구분합니다.

#### 타입 스케일 — System UI (SF Pro)

| 용도 | Font | Size | Weight | Letter Spacing | Line Height | Color Variable |
|---|---|---|---|---|---|---|
| Screen Title (헤더) | SF Pro | 18px | 600 (SemiBold) | -0.2 | — | `$text-primary` |
| Body (본문) | SF Pro | 15px | 500 (Medium) | — | 1.6 | `$text-primary` |
| Caption (캡션/라벨) | SF Pro | 13px | 500 (Medium) | — | — | `$text-secondary` |
| Meta (메타/출처) | SF Pro | 12px | 400 (Regular) | — | — | `$text-tertiary` |
| Button Label | SF Pro | 16px | 600 (SemiBold) | — | — | `#FFFFFF` |
| Filter Chip (Active) | SF Pro | 13px | 600 (SemiBold) | — | — | `#FFFFFF` |
| Filter Chip (Inactive) | SF Pro | 13px | 500 (Medium) | — | — | `$text-secondary` |
| Tag | SF Pro | 11px | 600 (SemiBold) | — | — | `$accent` / 해당 색상 |
| Tab Label (Active) | SF Pro | 10px | 600 (SemiBold) | — | — | `#FFFFFF` |
| Tab Label (Inactive) | SF Pro | 10px | 500 (Medium) | — | — | `$tab-inactive` |

#### 타입 스케일 — Share Card (Nanum Myeongjo)

| 용도 | Font | Size | Weight | Letter Spacing | Line Height | Color Variable |
|---|---|---|---|---|---|---|
| Quote Icon `"` | Nanum Myeongjo | 56px | 800 (ExtraBold) | — | 0.5 | 스타일별 |
| Quote Text (인용문) | Nanum Myeongjo | 20px | 400 (Regular) | -0.3 | 1.6 | 스타일별 |
| Author · Book (출처) | SF Pro | 12px | 500 (Medium) | — | — | 스타일별 |
| Bookmate Logo (워터마크) | Outfit | 13px | 700 (Bold) | -0.3 | — | 스타일별 |

#### 타입 스케일 — Brand & Misc

| 용도 | Font | Size | Weight | Letter Spacing | Line Height | Color Variable |
|---|---|---|---|---|---|---|
| Logo "Bookmate" | Outfit | 26px | 700 (Bold) | -0.5 | — | `$text-primary` |
| Status Bar Time | Inter | 16px | 600 (SemiBold) | — | — | `$text-primary` |

---

### 2.4 Icons — Lucide

| 아이콘명 | 용도 | 기본 크기 |
|---|---|---|
| `bell` | 알림 | 24px |
| `search` | 검색 | 24px |
| `scan` | 스캔/FAB | 24px |
| `chevron-left` | 뒤로가기 | 22px |
| `x` | 닫기 | 22px |
| `zap` | 플래시 | 22px |
| `signal` | 상태바 신호 | 16px |
| `wifi` | 상태바 와이파이 | 16px |
| `battery-full` | 상태바 배터리 | 16px |
| `ellipsis` | 더보기 | 24px |
| `house` | 탭 — 홈 | 18px |
| `circle-plus` | 탭 — 수집 | 18px |
| `user` | 탭 — 설정/MY | 18px |
| `book-open` | 탭 — 라이브러리 / 도서정보 | 18px |
| `save` | 저장 버튼 (Deep Focus) | 20px |
| `link` | 링크 복사 | 24px |
| `message-circle` | 메시지 공유 | 24px |
| `more-horizontal` | 더보기 공유 | 24px |
| `download` | 다운로드/저장 | 24px |

**아이콘 기본 색상**: `$text-primary` (Light) / `$df-text-primary` (Dark)

---

### 2.5 Spacing Scale

| 값 | 사용처 |
|---|---|
| **4px** | Pill padding, 인사말 gap |
| **6px** | 아이콘 간격, 태그 섹션 gap |
| **8px** | 뒤로가기 row gap, 스워치 내부 |
| **10px** | 입력 필드 내부 간격 |
| **12px** | 컴포넌트 내부, 스타일 옵션 |
| **16px** | 섹션 내부 gap (큐레이션/추천) |
| **20px** | 화면 수평 패딩, 카드 내부 gap, 스타일 섹션 gap |
| **24px** | 콘텐츠 섹션 gap, 하단 패딩 |
| **28px** | 홈 콘텐츠 gap, 카드 수평 패딩 |
| **32px** | 카드 수직 패딩, 바텀 패딩 |
| **40px** | 강조 카드 상단 패딩 |

---

### 2.6 Corner Radius

| 용도 | 값 |
|---|---|
| 카드 (Featured Quote, Share Card) | 20px |
| 공유 카드 | 24px |
| 버튼 (Primary) | 14px |
| 색상 스워치 | 12px |
| 탭바 Pill | 36px |
| Filter Chip / Tag | 100px (pill) |
| FAB | 100px (원형) |

### 2.7 Shadow

| 컴포넌트 | Color | Blur | Offset |
|---|---|---|---|
| 카드 (기본) | `rgba(26, 25, 24, 0.03)` (`#1A191808`) | 12px | (0, 2) |
| FAB | `#3D8A5A40` | 16px | (0, 4) |

---

## 3. Molecules — 조합 요소

> Atom들을 조합하여 하나의 기능 단위를 이루는 요소. 버튼, 필터 칩, 태그 등이 이에 해당합니다.

---

### 3.1 Filter Chip — Active

| 항목 | 값 |
|---|---|
| Background | `$text-primary` (`#1A1918`) |
| Text | SF Pro 13px / 600, `#FFFFFF` |
| Corner Radius | 100px (pill) |
| Padding | top/bottom: 8px, left/right: 16px |
| 동작 | 탭 → Inactive 상태 전환, 필터 해제 |

### 3.2 Filter Chip — Inactive

| 항목 | 값 |
|---|---|
| Background | 투명 |
| Stroke | `$border` (`#E5E4E1`), 1px, inside |
| Text | SF Pro 13px / 500, `$text-secondary` |
| Corner Radius | 100px (pill) |
| Padding | top/bottom: 8px, left/right: 16px |
| 동작 | 탭 → Active 상태 전환, 필터 적용 |

---

### 3.3 Tags

태그는 카테고리에 따라 색상이 다릅니다.

| 태그명 | 텍스트 색상 | 배경색 |
|---|---|---|
| 자아 | `$accent` (`#3D8A5A`) | `$accent-light` (`#C8F0D8`) |
| 사랑 | `#D89575` | `#FDE8D8` |
| 성장 | `#7B68EE` | `#E8E7FF` |
| 인생 | `#CC8800` | `#FFF3CD` |
| (기본) | `$text-secondary` (`#6D6C6A`) | `#E8E7E5` |

**공통 스타일:**

| 항목 | 값 |
|---|---|
| Font | SF Pro 11px / 600 |
| Corner Radius | 100px (pill) |
| Padding | top/bottom: 3px, left/right: 8px |

---

### 3.4 Primary Button (Save Button)

| 항목 | 값 |
|---|---|
| Width | `fill_container` (390px 전체 폭) |
| Height | 52px |
| Background | `$accent` (`#3D8A5A`) |
| Corner Radius | 14px |
| Text | "문장 저장하기", SF Pro 16px / 600, `#FFFFFF`, 중앙 정렬 |
| Layout | `justifyContent: center`, `alignItems: center` |

### 3.5 FAB (Floating Action Button)

| 항목 | 값 |
|---|---|
| Size | 56 × 56px |
| Background | `$accent` (`#3D8A5A`) |
| Corner Radius | 100px (원형) |
| Icon | `scan` (Lucide), 24px, `#FFFFFF` |
| Shadow | `#3D8A5A40`, blur: 16px, offset: (0, 4) |
| Position | absolute, 화면 우하단 (x: 314, y: 684) |
| Layout | `justifyContent: center`, `alignItems: center` |

### 3.6 Deep Focus Save Button

| 항목 | 값 |
|---|---|
| Width | 200px |
| Height | 52px |
| Background | `$accent` (`#3D8A5A`) |
| Corner Radius | 12px |
| Icon | `save` (Lucide), 20px, `#FFFFFF` |
| Text | "기록 저장", SF Pro 16px / 600, `#FFFFFF` |
| Layout | horizontal, gap: 8px, `justifyContent: center`, `alignItems: center` |

---

## 4. Organisms — 복합 컴포넌트

> Molecule들이 모여 하나의 독립적인 UI 영역을 구성합니다. 상태 바, 탭 바, 헤더, 카드 등 재사용 가능한 컴포넌트입니다.

---

### 4.1 Status Bar

| 항목 | 값 |
|---|---|
| Width | 390px (`fill_container`) |
| Height | 62px |
| Padding | top: 22, left: 20, right: 20 |
| Layout | horizontal, `justifyContent: space_between` |

**좌측:** 시간 텍스트 ("9:41", Inter 16px / 600, `$text-primary`)

**우측:** 아이콘 그룹 (horizontal, gap: 6px)
- `signal` — 16px, `$text-primary`
- `wifi` — 16px, `$text-primary`
- `battery-full` — 16px, `$text-primary`

---

### 4.2 Tab Bar — Light Theme

| 항목 | 값 |
|---|---|
| Width | 390px (`fill_container`) |
| Height | 90px |
| Background | `$bg` (`#F5F4F1`) |
| Padding | top: 12, left: 21, bottom: 21, right: 21 |

**Pill 컨테이너:**

| 항목 | 값 |
|---|---|
| Corner Radius | 36px |
| Background | `$card` (`#FFFFFF`) |
| Stroke | `$border` (`#E5E4E1`), 1px, inside |
| Padding | 4px |
| Layout | horizontal, `fill_container` |

**탭 구성 (3탭):**

| 탭 | 아이콘 | 라벨 | 활성 스타일 |
|---|---|---|---|
| 홈 | `house` | 홈 | fill: `$accent`, 아이콘/텍스트: `#FFFFFF` |
| 수집 | `circle-plus` | 수집 | 스캔 플로우 Modal 트리거 |
| 설정 | `user` | 설정 | — |

- 각 탭: cornerRadius 26px, vertical layout, gap: 4px, `justifyContent: center`, `alignItems: center`
- 비활성: 아이콘/텍스트 `$tab-inactive`, SF Pro 10px / 500

### 4.3 Tab Bar — Deep Focus Theme

| 항목 | 값 |
|---|---|
| Width | 390px |
| Height | 90px |
| Background | `$df-bg` (`#121412`) |
| Padding | top: 12, left: 21, bottom: 21, right: 21 |

**Pill 컨테이너:**

| 항목 | 값 |
|---|---|
| Corner Radius | 36px |
| Background | `$df-surface` (`#1A1C1A`) |
| Stroke | `$df-border` (`#3E423E`), 1px, inside |
| Padding | 4px |

**탭 구성 (4탭):**

| 탭 | 아이콘 | 라벨 |
|---|---|---|
| HOME | `house` | HOME |
| LIBRARY | `book-open` | LIBRARY |
| SCAN | `scan` | SCAN |
| MY | `user` | MY |

- 활성: fill `$df-accent`, 아이콘/텍스트 `#FFFFFF`
- 비활성: `$df-text-secondary`, Inter 10px / 600, letterSpacing: 0.5

---

### 4.4 Back Header

| 항목 | 값 |
|---|---|
| Width | 390px (`fill_container`) |
| Height | 52px |
| Padding | left: 20, right: 20 |
| Layout | horizontal, `justifyContent: space_between`, `alignItems: center` |

**좌측 (backRow):**
- Layout: horizontal, gap: 8px
- `chevron-left` icon — 22px, `$text-primary`
- 타이틀 텍스트 — SF Pro 18px / 600, `$text-primary`, letterSpacing: -0.2

**우측:**
- `x` icon — 22px, `$text-secondary`

---

### 4.5 Quote List Item

| 항목 | 값 |
|---|---|
| Width | 390px (`fill_container`) |
| Layout | vertical, gap: 10px |
| Padding | top: 20, bottom: 20 |

**인용 텍스트:**
- SF Pro 15px / 500, `$text-primary`, lineHeight: 1.6
- `textGrowth: fixed-width`, `width: fill_container`

**메타 행 (하단):**
- Layout: horizontal, gap: 6px
- 출처 텍스트: SF Pro 12px / 400, `$text-tertiary` (예: "데미안 · 헤르만 헤세")
- 태그 Chip: pill 스타일, fill: `$accent-light`, text: SF Pro 10px / 500, `$accent`

---

### 4.6 Featured Quote Card

| 항목 | 값 |
|---|---|
| Width | 390px (또는 `fill_container`) |
| Corner Radius | 20px |
| Background | `$card` (`#FFFFFF`) |
| Shadow | `#1A191808`, blur: 12px, offset: (0, 2) |
| Layout | vertical, gap: 20px |
| Padding | top: 32, left: 28, bottom: 32, right: 28 |

**내부 구성:**

1. **큰따옴표 아이콘**: `"` 텍스트, SF Pro 48px / 700, `$coral` (`#D89575`), lineHeight: 0.6
2. **인용문 텍스트**: SF Pro 18px / 500, `$text-primary`, letterSpacing: -0.2, lineHeight: 1.6, `textGrowth: fixed-width`, `width: fill_container`
3. **출처 행** (horizontal, gap: 8px):
   - 구분선: rectangle, 24 × 1px, `$border`
   - 출처 텍스트: SF Pro 13px / 500, `$text-tertiary` (예: "헤르만 헤세 · 데미안")

---

## 5. Templates — 화면 구성

> Organism들을 배치하여 완성된 화면 레이아웃을 구성합니다. 각 화면은 일관된 구조와 패턴을 따릅니다.

---

### 5.1 Screen Layout Spec (공통)

| 항목 | 값 |
|---|---|
| Screen Width | 390px |
| Screen Height | 844px |

#### 영역별 레이아웃

| 영역 | Height | Padding | 비고 |
|---|---|---|---|
| Status Bar | 62px | [22, 20, 0, 20] | 모든 화면 공통 |
| Header (홈) | 64px | [0, 20] | "Bookmate" 로고 + 알림 벨 |
| Header (서브 화면) | 52px | [0, 20] | backRow gap: 8 |
| Tab Bar | 90px | [12, 21, 21, 21] | pill padding: 4 |

#### Content Area 패딩/Gap 상세

| 화면 | Padding | Gap |
|---|---|---|
| 홈 | [0, 20, 24, 20] | 28px |
| 문장 수집 | [8, 20, 24, 20] | 24px |
| 카드 꾸미기 | [20, 32] | 20px |
| 도서 선택 | [8, 20, 24, 20] | 24px |
| 문장 선택 | [24, 20] | 8px |

#### 컴포넌트 레이아웃 스펙

| 컴포넌트 | Padding | Gap | Corner Radius |
|---|---|---|---|
| Featured Quote Card | [32, 28] | 20px | 20px |
| Share Card | [40, 32] | 24px | 24px |
| Primary Button | — | — | 14px |
| Tab Bar | [12, 21, 21, 21] | — | pill: 36px |
| Book Info Row | — | 16px | — |

---

### 5.2 Template 목록

| # | 화면명 | Screen ID | 배경 | 특징 |
|---|---|---|---|---|
| 1 | 홈 | `a3p4g` | `$bg` | Status Bar + Header + Content(Featured Quote, 큐레이션, 추천) + Tab Bar |
| 2 | 문장 수집 | `nzcgh` | `$bg` | Status Bar + Back Header + Content(책 정보, 메모, 인용문, 태그) + Save Button |
| 3 | 내 문장 | `jeZEu` | `$bg` | Status Bar + Header + Filter Row + Quote List + FAB + Tab Bar |
| 4 | 문구 스캔 | `p67S4` | `#000000` | Status Bar + Camera Header + Book Info Bar + Viewfinder + Bottom Controls |
| 5 | 도서 매칭 | `KjHwV` | `$bg` | Status Bar + Header + 검색바 + 최근 도서 목록 (Bottom Sheet overlay) |

---

### 5.3 화면별 레이아웃 구조

#### Template 1: 홈 (`a3p4g`)

```
┌─────────────────────────────┐
│ Status Bar (H: 62)          │  ← padding: [22, 20, 0, 20]
├─────────────────────────────┤
│ Header (H: 64)              │  ← "Bookmate" 로고 (Outfit 26/700, brand logo) + bell icon
│   [Logo]            [Bell]  │     padding: [0, 20], space_between
├─────────────────────────────┤
│ Content                     │  ← padding: [0, 20, 24, 20], gap: 28
│   ┌─ Date/Title ──────────┐│
│   │ "3월 19일 수요일"       ││
│   │ "오늘의 문장"           ││
│   └────────────────────────┘│
│   ┌─ Featured Quote Card ─┐│  ← cornerRadius: 20, shadow, padding: [32, 28]
│   │  "  (coral)            ││
│   │  인용문 텍스트           ││
│   │  ── 저자 · 책명         ││
│   └────────────────────────┘│
│   ┌─ Curation Section ────┐│
│   │ "큐레이션"    "더보기 >"││
│   │ [Card] [Card] [Card]   ││  ← 가로 스크롤
│   └────────────────────────┘│
│   ┌─ Recommend Section ───┐│
│   │ "이런 문장은 어때요?"    ││
│   │ [Recommend Card]       ││
│   └────────────────────────┘│
├─────────────────────────────┤
│ Tab Bar (H: 90)             │  ← [홈(active)] [수집] [설정]
└─────────────────────────────┘
```

#### Template 2: 문장 수집 (`nzcgh`)

```
┌─────────────────────────────┐
│ Status Bar (H: 62)          │
├─────────────────────────────┤
│ Back Header (H: 52)         │  ← [< 문장 수집]         [X]
├─────────────────────────────┤
│ Content                     │  ← padding: [8, 20, 24, 20], gap: 24
│   ┌─ Book Info ───────────┐│
│   │ [Cover] 책명 · 저자     ││  ← 60×84 thumbnail, gap: 16
│   └────────────────────────┘│
│   ┌─ 나의 메모 ────────────┐│
│   │ placeholder: "이 문장에 ││  ← H: 80
│   │ 대한 메모를 남겨보세요"  ││
│   └────────────────────────┘│
│   ┌─ 인용문 섹션 ──────────┐│
│   │ [Scan CTA Banner]      ││
│   │ "선택된 문장 텍스트"     ││
│   └────────────────────────┘│
│   ┌─ 태그 섹션 ────────────┐│
│   │ [자아] [사랑] [+ 태그]  ││
│   └────────────────────────┘│
├─────────────────────────────┤
│ Save Button (H: 52)         │  ← "문장 저장하기", $accent, cornerRadius: 14
└─────────────────────────────┘
```

#### Template 3: 내 문장 (`jeZEu`)

```
┌─────────────────────────────┐
│ Status Bar (H: 62)          │
├─────────────────────────────┤
│ Header (H: 64)              │  ← "내 문장" (Outfit 26/700, brand logo) + badge + search icon
├─────────────────────────────┤
│ Filter Row                  │  ← padding: [0, 20], gap: 8
│ [전체] [미지정] [자아] [성장] [사랑] [위로]
├─────────────────────────────┤
│ Quote List                  │  ← padding: [16, 20, 0, 20]
│   ┌─ QuoteListItem ───────┐│
│   │ 인용 텍스트 (15/500)    ││  ← lineHeight: 1.6
│   │ 출처 · 저자   [태그]    ││  ← gap: 6
│   └────────────────────────┘│
│   ┌─ QuoteListItem ───────┐│
│   │ ...                    ││
│   └────────────────────────┘│
│                         [FAB]│  ← 56×56, absolute(314, 684)
├─────────────────────────────┤
│ Tab Bar (H: 90)             │
└─────────────────────────────┘
```

#### Template 4: 문구 스캔 (`p67S4`)

```
┌─────────────────────────────┐  ← bg: #000000
│ Status Bar (H: 62)          │
├─────────────────────────────┤
│ Camera Header (H: 52)       │  ← [X]  "문장 스캔"  [zap]
├─────────────────────────────┤
│ Book Info Bar (H: 44)       │  ← bg: #1A1A1A, [book-open] "책명 · 저자명"
├─────────────────────────────┤
│                             │
│   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   │
│   │  Viewfinder Area    │   │  ← 카메라 프리뷰 + $accent 코너 가이드
│   │                     │   │
│   │  "텍스트가 포함된     │   │
│   │   페이지를 촬영하세요" │   │
│   └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘   │
│                             │
├─────────────────────────────┤
│ Bottom Controls (H: 120)    │  ← bg: #000000, padding: [20, 40, 30, 40]
│  [Gallery]  [Shutter]  [T]  │     space_between
└─────────────────────────────┘
```

#### Template 5: 도서 선택 (Bottom Sheet — `KjHwV`)

```
┌─────────────────────────────┐
│ Status Bar (H: 62)          │
├─────────────────────────────┤
│ Header (H: 52)              │  ← "도서 선택"           [X]
├─────────────────────────────┤
│ Content                     │  ← padding: [8, 20, 24, 20], gap: 24
│   ┌─ 검색바 ──────────────┐│
│   │ [🔍] "책 제목 또는      ││  ← 카드 스타일 컨테이너
│   │  저자를 검색하세요"      ││
│   └────────────────────────┘│
│   ┌─ 최근 도서 섹션 ───────┐│
│   │ "최근"                  ││
│   │ [Cover] 책 제목 · 저자  ││
│   │ [Cover] 책 제목 · 저자  ││
│   └────────────────────────┘│
└─────────────────────────────┘
```

---

## 6. 카드 스타일 프리셋 (Card Customization)

카드 꾸미기 화면에서 선택 가능한 공유 카드 스타일 프리셋입니다.

### 6.1 카드 기본 사양

| 항목 | 값 |
|---|---|
| Size | 327 × 420px |
| Corner Radius | 24px |
| Padding | [40, 32] |
| Gap | 24px |
| Layout | vertical |

### 6.2 스타일 프리셋

| # | 스타일명 | 배경 | 텍스트/아이콘 색상 |
|---|---|---|---|
| 1 | Green | `$accent` (`#3D8A5A`) | `#FFFFFF` |
| 2 | Coral | `$coral` (`#D89575`) | `#FFFFFF` |
| 3 | Dark | `#1A1918` | `#FFFFFF` |
| 4 | White | `#FFFFFF` | `$text-primary` |
| 5 | Blue | Blue 계열 | `#FFFFFF` |
| 6 | Photo | 사진 배경 + dark overlay | `#FFFFFF` |

### 6.3 카드 내부 구성

```
┌──────────────────────────┐
│  "  (큰따옴표 아이콘)      │  ← Nanum Myeongjo 56px / 800 (ExtraBold)
│                          │
│  선택한 문장 텍스트         │  ← Nanum Myeongjo 20px / 400, lineHeight: 1.6
│                          │
│  ── 책명 · 저자명          │  ← SF Pro 12px / 500, 출처
│                          │
│          Bookmate         │  ← Outfit 13px / 700, 워터마크 로고
└──────────────────────────┘
```

---

## 7. 디자인 토큰 요약 (Quick Reference)

### iOS UIKit 구현용 빠른 참조

```swift
// MARK: - Colors (Light Theme)
static let accent       = UIColor(hex: "#3D8A5A")
static let accentLight  = UIColor(hex: "#C8F0D8")
static let bg           = UIColor(hex: "#F5F4F1")
static let card         = UIColor(hex: "#FFFFFF")
static let coral        = UIColor(hex: "#D89575")
static let border       = UIColor(hex: "#E5E4E1")
static let textPrimary  = UIColor(hex: "#1A1918")
static let textSecondary = UIColor(hex: "#6D6C6A")
static let textTertiary = UIColor(hex: "#9C9B99")
static let tabInactive  = UIColor(hex: "#A8A7A5")

// MARK: - Colors (Dark / Deep Focus Theme)
static let dfAccent        = UIColor(hex: "#3D8A5A")
static let dfHighlight     = UIColor(hex: "#7FB685")
static let dfBg            = UIColor(hex: "#121412")
static let dfCard          = UIColor(hex: "#2D302D")
static let dfSurface       = UIColor(hex: "#1A1C1A")
static let dfBorder        = UIColor(hex: "#3E423E")
static let dfTextPrimary   = UIColor(hex: "#E9ECEF")
static let dfTextSecondary = UIColor(hex: "#ADB5BD")
static let dfTextOnAccent  = UIColor(hex: "#FAFAFA")

// MARK: - Typography
// System UI: SF Pro (headers, body, captions, buttons, tags)
// Share Card: Nanum Myeongjo (quote icon, quote text — literary/serif)
// Brand Logo: Outfit ("Bookmate" only)
// Numeric/Tech: Inter (status bar time)

// MARK: - Corner Radius
static let cardRadius: CGFloat    = 20
static let buttonRadius: CGFloat  = 14
static let chipRadius: CGFloat    = 100  // pill
static let tabPillRadius: CGFloat = 36
static let fabRadius: CGFloat     = 100  // circle

// MARK: - Sizing
static let buttonHeight: CGFloat     = 52
static let statusBarHeight: CGFloat  = 62
static let headerHeight: CGFloat     = 52  // sub screens
static let homeHeaderHeight: CGFloat = 64
static let tabBarHeight: CGFloat     = 90
static let fabSize: CGFloat          = 56
static let screenHPadding: CGFloat   = 20
```

---

## 8. 디자인 파일 Node ID 참조

| 구분 | Node ID | 설명 |
|---|---|---|
| **Design System** | `xHavm` | Atomic Design System 전체 프레임 |
| **Atoms** | `b5Fbe` | 기본 요소 섹션 |
| — Colors Light | `oE4my`, `vY9NC` | 라이트 테마 색상 |
| — Colors Dark | `UtwOJ` | 다크 테마 색상 |
| — Typography | `jhbou` | 타이포그래피 |
| — Icons | `XwjZN` | 아이콘 |
| — Spacing | `QLoUQ` | 스페이싱 |
| **Molecules** | `o2Cg2` | 조합 요소 섹션 |
| — Filter Chips | `PWfZV` | 필터 칩 |
| — Buttons | `xjQN7` | 버튼 |
| — Tags | `eH3y3`, `yiJwV` | 태그 |
| **Organisms** | `7hIJq` | 복합 컴포넌트 섹션 |
| — Status Bar | `5Lrrl` | 상태 바 |
| — Tab Bar | `QpB0M` | 탭 바 |
| — Back Header | `lE5UF` | 뒤로가기 헤더 |
| — Quote List Item | `ngz1g` | 인용문 리스트 아이템 |
| — Featured Quote Card | `eUQBq` | 피쳐드 인용문 카드 |
| **Templates** | `huxNt` | 화면 구성 섹션 |
| — Template Grid | `6rsvZ` | 템플릿 미리보기 그리드 |
