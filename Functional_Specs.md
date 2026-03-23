# Bookmate — 기능정의서 (Functional Specification)

> 책에서 발견한 문장을 스캔하고, 꾸미고, 나만의 컬렉션으로 쌓아가는 독서 기록 앱

---

## 1. 문서 개요

| 항목 | 내용 |
|---|---|
| 프로젝트명 | Bookmate |
| 문서 버전 | 1.0 |
| 작성일 | 2026-03-20 |
| 대상 플랫폼 | iOS (iPhone) |
| UI 프레임워크 | UIKit |
| 최소 지원 버전 | iOS 16.0+ |
| 화면 해상도 기준 | 390 × 844 pt (iPhone 14 기준) |

### 기술 스택

| 분류 | 기술 |
|---|---|
| UI | UIKit (코드 기반) + SnapKit (Auto Layout DSL) |
| 반응형 프로그래밍 | RxSwift / RxCocoa |
| 네트워킹 | Alamofire |
| 이미지 로딩 | Kingfisher |
| 카메라 | AVFoundation |
| OCR | Vision Framework (`VNRecognizeTextRequest`) |
| 이미지 저장 | PHPhotoLibrary |
| 로컬 저장소 | RealmSwift |
| 카드 렌더링 | UIGraphicsImageRenderer |
| 공유 | UIActivityViewController |
| 도서 검색 API | Naver Books API |
| 패키지 관리 | Swift Package Manager (SPM) |

---

## 2. 디자인 시스템 정의

### 2.1 색상 변수 (Color Variables)

#### Light Theme

| 변수명 | HEX | 용도 |
|---|---|---|
| `accent` | `#3D8A5A` | 주 액센트 (forest green) — 버튼, 선택 상태, FAB, 탭 활성 |
| `accent-light` | `#C8F0D8` | 액센트 보조 (mint) — 태그 배경 |
| `bg` | `#F5F4F1` | 앱 배경색 (off-white) |
| `card` | `#FFFFFF` | 카드/컨테이너 배경 |
| `coral` | `#D89575` | 보조 색상 — 큰따옴표 아이콘, 강조 |
| `border` | `#E5E4E1` | 테두리, 구분선 |
| `text-primary` | `#1A1918` | 주 텍스트 |
| `text-secondary` | `#6D6C6A` | 보조 텍스트 |
| `text-tertiary` | `#9C9B99` | 3차 텍스트 (메타 정보) |
| `tab-inactive` | `#A8A7A5` | 탭바 비활성 아이콘/텍스트 |

#### Dark Theme (Deep Focus)

| 변수명 | HEX | 용도 |
|---|---|---|
| `df-accent` | `#3D8A5A` | 액센트 (Light와 동일) |
| `df-highlight` | `#7FB685` | 하이라이트 (accent-light 대체) |
| `df-bg` | `#121412` | 앱 배경 |
| `df-card` | `#2D302D` | 카드 배경 |
| `df-surface` | `#1A1C1A` | 서피스 (탭바 pill 배경 등) |
| `df-border` | `#3E423E` | 테두리, 구분선 |
| `df-text-primary` | `#E9ECEF` | 주 텍스트 |
| `df-text-secondary` | `#ADB5BD` | 보조 텍스트 |
| `df-text-on-accent` | `#FAFAFA` | 액센트 배경 위 텍스트 |

### 2.2 타이포그래피

| 용도 | Font | Size | Weight | 비고 |
|---|---|---|---|---|
| 로고 | Outfit | 26px | 700 (Bold) | letterSpacing: -0.3 |
| 섹션 타이틀 | SF Pro (System) | 22px | 600 (SemiBold) | — |
| 헤더 타이틀 | SF Pro (System) | 18px | 600 (SemiBold) | letterSpacing: -0.2 |
| 본문 | SF Pro (System) | 15px | 500 (Medium) | lineHeight: 1.6 |
| 버튼 라벨 | SF Pro (System) | 16px | 600 (SemiBold) | — |
| 필터 칩 | SF Pro (System) | 13px | 600 (Active) / 500 (Inactive) | — |
| 메타 텍스트 | SF Pro (System) | 12px | 400 (Regular) | — |
| 탭 라벨 | SF Pro (System) | 10px | 600 (Active) / 500 (Inactive) | — |
| 태그 | SF Pro (System) | 11px | 600 (SemiBold) | — |
| 공유 카드 인용문 | Nanum Myeongjo | 20px | 400 (Regular) | lineHeight: 1.6 |
| 공유 카드 큰따옴표 | Nanum Myeongjo ExtraBold | 56px | 800 | — |
| 상태바 시간 | Inter | 16px | 600 | — |

### 2.3 공통 레이아웃 규칙

| 항목 | 값 |
|---|---|
| 카드 cornerRadius | 20px |
| 카드 shadow | `rgba(26,25,24,0.05)`, blur 12px, offset (0, 2) |
| 버튼 높이 | 52px |
| 버튼 cornerRadius | 14px |
| 화면 좌우 패딩 | 20px |
| 콘텐츠 섹션 gap | 24–28px |
| 아이콘 시스템 | Lucide Icons |
| 아이콘 기본 크기 | 22px (헤더) / 18px (탭) / 16px (상태바) / 24px (FAB) |

---

## 3. 공통 컴포넌트 기능 정의

### 3.1 StatusBar

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `jyGkS` |
| 크기 | W: fill_container, H: 62px |
| 패딩 | top: 22, left: 20, right: 20 |
| 레이아웃 | 수평 (space_between) |
| 구성 | 좌: 시간 텍스트 ("9:41", Inter 16/600) / 우: 아이콘 그룹 (signal + wifi + battery-full, gap: 6) |
| 색상 | 텍스트/아이콘: `$text-primary` (Light) / `$df-text-primary` (Dark) |
| 동작 | 시스템 상태 표시 전용, 터치 불가 |

### 3.2 TabBar

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `g0KPo` (Light) / `PQLjQ` (Deep Focus) |
| 크기 | W: fill_container, H: 90px |
| 패딩 | top: 12, left: 21, bottom: 21, right: 21 |
| 배경 | `$bg` (Light) / `$df-bg` (Dark) |
| Pill 컨테이너 | cornerRadius: 36, fill: `$card` / `$df-surface`, stroke: `$border` / `$df-border` 1px inside, padding: 4 |

#### Light 탭 구성 (3탭)

| 탭 | 아이콘 | 라벨 | 활성 시 |
|---|---|---|---|
| 홈 | `house` | 홈 | fill: `$accent`, 아이콘/텍스트: white |
| 수집 | `circle-plus` | 수집 | 스캔 플로우 시작 (Modal) |
| 설정 | `user` | 설정 | — |

비활성 탭: 아이콘/텍스트 `$tab-inactive`, SF Pro 10/500

#### Deep Focus 탭 구성 (4탭)

| 탭 | 아이콘 | 라벨 |
|---|---|---|
| HOME | `house` | HOME |
| LIBRARY | `book-open` | LIBRARY |
| SCAN | `scan` | SCAN |
| MY | `user` | MY |

비활성 탭: `$df-text-secondary`, Inter 10/600, letterSpacing: 0.5

**동작:**
- 탭 선택 시 해당 탭 fill `$accent` / `$df-accent`, 아이콘/텍스트 white
- 중앙 "수집" 탭 → 스캔 플로우 Modal 전환 (도서 선택 화면)

### 3.3 FAB (Floating Action Button)

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `pirfI` |
| 크기 | 56 × 56px |
| cornerRadius | 100 (원형) |
| 배경 | `$accent` |
| 아이콘 | `scan` (Lucide), 24px, white |
| Shadow | `#3D8A5A40`, blur: 16, offset: (0, 4) |
| 위치 | 화면 우하단 (absolute, x: 314, y: 684) |
| 동작 | 탭 → 스캔 플로우 시작 (도서 선택 화면, Modal) |

### 3.4 FilterChip (Active)

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `KB1eI` |
| cornerRadius | 100 (pill) |
| 배경 | `$text-primary` |
| 패딩 | top/bottom: 8, left/right: 16 |
| 텍스트 | SF Pro 13/600, fill: white |
| 동작 | 탭 → 비활성(Inactive) 상태로 전환, 해당 태그 필터 해제 |

### 3.5 FilterChip (Inactive)

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `wHEJR` |
| cornerRadius | 100 (pill) |
| 배경 | 투명 |
| Stroke | `$border`, 1px, inside |
| 패딩 | top/bottom: 8, left/right: 16 |
| 텍스트 | SF Pro 13/500, fill: `$text-secondary` |
| 동작 | 탭 → 활성(Active) 상태로 전환, 해당 태그 필터 적용 |

### 3.6 QuoteListItem

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `49gUy` |
| 레이아웃 | 수직 (vertical), gap: 10 |
| 패딩 | top/bottom: 20 |
| 구성 요소 | |
| — 인용 텍스트 | SF Pro 15/500, `$text-primary`, lineHeight: 1.6, fixed-width |
| — 메타 행 | 수평, gap: 6 |
| —— 출처 | SF Pro 12/400, `$text-tertiary` (예: "데미안 · 헤르만 헤세") |
| —— 태그 | pill chip, fill: `$accent-light`, text: SF Pro 10/500 `$accent` |
| 동작 | 탭 → 문장 상세 보기 (미설계, 추후 추가) |

### 3.7 SaveButton

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `DpEfU` |
| 크기 | W: fill_container (390), H: 52px |
| cornerRadius | 14 |
| 배경 | `$accent` |
| 텍스트 | "문장 저장하기", SF Pro 16/600, white, 중앙 정렬 |
| 동작 | 탭 → 해당 화면의 저장/확인 액션 실행 |

### 3.8 BackHeader

| 항목 | 내용 |
|---|---|
| 컴포넌트 ID | `gjcCN` |
| 크기 | W: fill_container (390), H: 52px |
| 패딩 | left/right: 20 |
| 레이아웃 | 수평 (space_between) |
| 좌측 | backRow: chevron-left (22px, `$text-primary`) + 타이틀 (SF Pro 18/600, `$text-primary`), gap: 8 |
| 우측 | X 아이콘 (22px, `$text-secondary`) |
| 동작 | chevron-left 탭 → 이전 화면 pop / X 탭 → 플로우 dismiss |

---

## 4. 화면별 기능 정의

---

### 4.1 홈 (`a3p4g`)

| 항목 | 내용 |
|---|---|
| Screen ID | `a3p4g` |
| 화면명 | 1 홈 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 앱 진입 시 오늘의 문장과 큐레이션 콘텐츠 노출 |
| 진입 조건 | 앱 실행 시 기본 화면 / 탭바 "홈" 탭 선택 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `bj6JC` | H: 62, padding: [22,20,0,20] |
| Header | `EfWUR` | H: 64, padding: [0,20], space_between — "Bookmate" 로고 (Outfit 26/700) + 알림 벨 아이콘 |
| Content | `XXfd5` | vertical, gap: 28, padding: [0,20,24,20], fill_container |
| Tab Bar | `ABZPx` | H: 90, fill: `$bg`, padding: [12,21,21,21] |

#### Content 영역 상세

1. **날짜/타이틀 섹션**: "3월 19일 수요일" + "오늘의 문장"
2. **Featured Quote 카드**: 큰따옴표 아이콘 (`$coral`) + 인용문 텍스트 + 출처 (책명 · 저자명), 카드 shadow 적용
3. **Curation Section**: 섹션 헤더 ("큐레이션" + "더보기" 링크) + 가로 스크롤 카드 목록
4. **Recommend Section**: "이런 문장은 어때요?" 타이틀 + 추천 문장 카드

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| Featured Quote 카드 탭 | 문장 상세 보기 | 문장 상세 (미설계) |
| 큐레이션 카드 탭 | 해당 문장 상세 보기 | 문장 상세 (미설계) |
| 알림 벨 아이콘 탭 | 알림 목록 | 미설계 |
| 탭바 "수집" (중앙) 탭 | 스캔 플로우 시작 | → 2 도서 선택 (Modal) |
| 탭바 "내 문장" 탭 | 내 문장 목록 전환 | → 7 내 문장 |

#### 데이터

- **입력**: 없음 (앱 초기 로드)
- **출력**: 오늘의 추천 문장 (Quote), 큐레이션 목록 (Quote[]), 추천 문장 목록 (Quote[])

#### 예외/엣지 케이스

- 저장된 문장이 없을 경우: 기본 큐레이션 콘텐츠 또는 빈 상태 안내 표시
- 오늘의 문장 선정 로직: 저장된 문장 중 랜덤 or 최신 순

---

### 4.2 도서 선택 (`KjHwV`)

| 항목 | 내용 |
|---|---|
| Screen ID | `KjHwV` |
| 화면명 | 2 도서 선택 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 문장을 수집할 도서 지정 |
| 진입 조건 | 홈 탭바 중앙 버튼 or FAB 탭 (Modal 전환) |
| 이전 화면 | 1 홈 / 7 내 문장 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `eo0DV` | H: 62, padding: [22,20,0,20] |
| Header | `xl8g3` | H: 52, padding: [0,20], space_between — "도서 선택" 타이틀 + X (닫기) |
| Content | `H73kt` | vertical, gap: 24, padding: [8,20,24,20], fill_container |

#### Content 영역 상세

1. **검색바**: 돋보기 아이콘 + "책 제목 또는 저자를 검색하세요" placeholder, 카드 스타일
2. **최근 도서 섹션**: "최근" 섹션 헤더 + 최근 선택한 도서 목록 (커버 + 제목 + 저자)

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 검색바 입력 | 도서 검색 결과 표시 | 현재 화면 내 |
| 도서 항목 탭 | 해당 도서 선택 | → 3-1 사진 촬영 |
| X (닫기) 탭 | 플로우 중단 | ← 홈으로 복귀 (dismiss) |

#### 데이터

- **입력**: 검색 키워드 (String)
- **출력**: 선택된 Book 객체
- **저장**: 최근 선택 도서 목록 업데이트 (로컬)

#### 예외/엣지 케이스

- 검색 결과 없음 → "검색 결과가 없습니다" 안내
- 최근 도서 없음 → 빈 상태 또는 도서 직접 입력 유도
- 도서 검색 API 실패 시 → 오프라인 안내 또는 직접 입력 옵션

---

### 4.3 사진 촬영 (`p67S4`)

| 항목 | 내용 |
|---|---|
| Screen ID | `p67S4` |
| 화면명 | 3-1 사진 촬영 |
| 크기 | 390 × 844px |
| 배경 | `#000000` |
| 레이아웃 | 수직 (vertical), clip: true |
| 목적 | 카메라로 책 페이지 촬영 |
| 진입 조건 | 도서 선택 완료 후 자동 전환 |
| 이전 화면 | 2 도서 선택 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `M4BbW` | H: 62, padding: [22,24,0,24] |
| Camera Header | `PK3hR` | H: 52, padding: [0,20], space_between — X(닫기) / "문장 스캔" / 플래시(zap) |
| Book Info Bar | `EAMeO` | H: 44, padding: [0,20], fill: `#1A1A1A`, gap: 8 — book-open 아이콘 + "책명 · 저자명" |
| Viewfinder Area | `KG9yX` | fill_container, 카메라 프리뷰 영역 |
| Bottom Controls | `AjFc7` | H: 120, fill: `#000000`, padding: [20,40,30,40], space_between |

#### 카메라 헤더 상세

- 좌: X 닫기 아이콘 (흰색)
- 중: "문장 스캔" 텍스트 (흰색)
- 우: zap (플래시) 아이콘 (흰색)

#### 뷰파인더 영역

- 카메라 실시간 프리뷰 (AVCaptureVideoPreviewLayer)
- 코너 가이드라인 4개 (`$accent` 색상) — 촬영 영역 안내
- 힌트 텍스트: "텍스트가 포함된 페이지를 촬영하세요"

#### 하단 컨트롤

- 좌: 갤러리 버튼 (최근 사진 썸네일)
- 중앙: 셔터 버튼 (흰색 원 테두리)
- 우: T 버튼 (텍스트 직접 입력 모드)

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 셔터 버튼 탭 | 사진 촬영 | → 3-2 사진 확인 |
| 갤러리 버튼 탭 | 포토 라이브러리 열기 | UIImagePickerController → 3-2 사진 확인 |
| T 버튼 탭 | 텍스트 직접 입력 모드 | → ManualQuoteEntryViewController (직접 입력 전용 화면) |
| 플래시 아이콘 탭 | 플래시 on/off 토글 | 현재 화면 내 |
| X (닫기) 탭 | 플로우 중단 | ← dismiss |

#### 데이터

- **입력**: 선택된 Book 정보 (Book Info Bar에 표시)
- **출력**: 촬영된 UIImage

#### 필수 권한

- `NSCameraUsageDescription` — 카메라 접근 권한
- `NSPhotoLibraryUsageDescription` — 사진 라이브러리 접근 권한 (갤러리 선택 시)

#### 예외/엣지 케이스

- 카메라 권한 미허용 → 설정 이동 안내 Alert
- 저조도 환경 → 플래시 사용 유도 힌트
- 갤러리 접근 권한 미허용 → 설정 이동 안내

---

### 4.4 사진 확인 (`Qd8np`)

| 항목 | 내용 |
|---|---|
| Screen ID | `Qd8np` |
| 화면명 | 3-2 사진 확인 |
| 크기 | 390 × 844px |
| 배경 | `#000000` |
| 레이아웃 | 수직 (vertical), clip: true |
| 목적 | 촬영된 사진 품질 확인 후 진행 여부 결정 |
| 진입 조건 | 사진 촬영 완료 또는 갤러리 선택 완료 |
| 이전 화면 | 3-1 사진 촬영 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `ZFEnm` | H: 62, padding: [22,24,0,24] |
| Photo Area | `tiTHM` | fill_container — 촬영 이미지 전체화면 표시 |
| Button Bar | `HYghC` | padding: [16,20,40,20], gap: 12, 수평 정렬 |

#### 하단 버튼

1. **"다시 촬영"** — 아웃라인 스타일 (투명 배경 + 흰색 테두리 + 흰색 텍스트)
2. **"텍스트 인식"** — 솔리드 스타일 (`$accent` fill + 흰색 텍스트)

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| "다시 촬영" 탭 | 현재 이미지 폐기 | ← 3-1 사진 촬영 (pop) |
| "텍스트 인식" 탭 | OCR 처리 시작 | → 3-3 텍스트 인식 |

#### 데이터

- **입력**: 촬영된 UIImage
- **출력**: OCR 처리 완료된 텍스트 결과 (VNRecognizedTextObservation[])

#### 예외/엣지 케이스

- OCR 처리 중 로딩 인디케이터 표시
- 텍스트 인식 실패 (이미지에 텍스트 없음) → 안내 Alert + 다시 촬영 유도

---

### 4.5 텍스트 인식 (`VRu1h`)

| 항목 | 내용 |
|---|---|
| Screen ID | `VRu1h` |
| 화면명 | 3-3 텍스트 인식 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | OCR 인식 결과 확인 및 인식 설정 조정 |
| 진입 조건 | 사진 확인 → "텍스트 인식" 탭 |
| 이전 화면 | 3-2 사진 확인 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `eycpU` | H: 62, padding: [21,27] |
| Header | `zlrdO` | H: 48, padding: [0,16], center 정렬 — chevron-left + "텍스트 인식" |
| Photo Section | `rgl8M` | H: 340, padding: [8,16,16,16], vertical — 사진 미리보기 + OCR 하이라이트 |
| Card Wrapper | `PqfPH` | padding: [0,16], vertical — 설정 카드 |
| Spacer | `1jwHC` | fill_container |
| Bottom Action | `spqsL` | padding: [16,20,32,20], vertical — "텍스트 확인하기" 버튼 |

#### Photo Section 상세

- 촬영 이미지 축소 미리보기
- OCR 인식 영역 하이라이트: `$accent` 반투명 사각형으로 인식된 텍스트 라인 5개 표시

#### 설정 카드 상세

카드 스타일 컨테이너 내 3개 설정 행:

| 설정 | 설명 | UI |
|---|---|---|
| 정확도 (Accuracy) | OCR 인식 정확도 레벨 | 토글/슬라이더 |
| 교정 (Correction) | 자동 텍스트 교정 | 토글 스위치 |
| 언어 (Language) | 인식 언어 선택 (한국어/영어 등) | 선택 UI |

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| chevron-left 탭 | 이전 화면 | ← 3-2 사진 확인 |
| 설정 조정 | OCR 파라미터 변경 | 현재 화면 내 (재인식) |
| "텍스트 확인하기" 탭 | 인식 결과 확정 | → 4 문장 선택 |

#### 데이터

- **입력**: 촬영 이미지 + OCR 결과 (VNRecognizedTextObservation[])
- **출력**: 확정된 텍스트 라인 배열 (String[])

---

### 4.6 문장 선택 (`ZZQXo`)

| 항목 | 내용 |
|---|---|
| Screen ID | `ZZQXo` |
| 화면명 | 4 문장 선택 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 인식된 텍스트 중 수집할 줄을 직접 선택 |
| 진입 조건 | 텍스트 인식 → "텍스트 확인하기" 탭 |
| 이전 화면 | 3-3 텍스트 인식 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `xwqKp` | H: 62, padding: [22,20,0,20] |
| Header | `CdTR9` | H: 52, padding: [0,20], space_between — chevron-left + "문장 선택" / "최대 3줄" subtitle |
| Content | `RFIwJ` | fill_container, vertical, gap: 8, padding: [24,20], center 정렬 |
| Bottom | `IW9y4` | padding: [16,20,32,20], vertical, center 정렬 — "계속" 버튼 |

#### 텍스트 목록 상세

- 줄 단위로 인식된 텍스트를 행(row)으로 나열
- 각 행은 탭으로 선택/해제 토글

| 상태 | 스타일 |
|---|---|
| 선택됨 | fill: `$accent`, 텍스트: white, cornerRadius 적용 |
| 미선택 | fill: 투명, 텍스트: `$text-secondary` |

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 텍스트 행 탭 | 선택/해제 토글 | 현재 화면 내 |
| chevron-left 탭 | 이전 화면 | ← 3-3 텍스트 인식 |
| "계속" 버튼 탭 | 선택한 줄 연결하여 문장 구성 | → 5 카드 꾸미기 |

#### 데이터

- **입력**: OCR 인식된 텍스트 라인 배열 (String[])
- **출력**: 선택된 라인들을 합친 문장 텍스트 (String)

#### 비즈니스 룰

- **최대 3줄** 선택 제한 (연속 선택만 가능)
- 3줄 초과 선택 시 → 선택 불가 + 안내 표시 ("최대 3줄까지 선택 가능합니다")
- 최소 1줄 선택 필수 → 0줄 선택 시 "계속" 버튼 비활성화

---

### 4.7 카드 꾸미기 (`v8DT8` / `jz2Vy`)

| 항목 | 내용 |
|---|---|
| Screen ID | `v8DT8` (색상 배경) / `jz2Vy` (사진 배경) |
| 화면명 | 5 카드 꾸미기 / 5-1-2 카드 꾸미기 (사진 배경) |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 수집한 문장을 공유 가능한 카드 이미지로 꾸미기 |
| 진입 조건 | 문장 선택 → "계속" 탭 |
| 이전 화면 | 4 문장 선택 |

#### UI 구성 요소 (색상 배경 — `v8DT8`)

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `jDAQ2` | H: 62, padding: [22,20,0,20] |
| Header | `B9GeB` | H: 52, padding: [0,20], space_between — chevron-left + "카드 꾸미기" / X(닫기) |
| Card Area | `bJDbA` | fill_container, vertical, center 정렬, padding: [20,32] |
| Style Section | `a0lza` | vertical, gap: 20, padding: [0,20,32,20] |

#### UI 구성 요소 (사진 배경 — `jz2Vy`)

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `tedkT` | H: 62 |
| Header | `NjRZ2` | H: 52 |
| Card Area | `ejFkF` | fill_container, center 정렬 |
| Style Section | `CfNGS` | vertical, gap: 20 |

#### 카드 미리보기

- 크기: 327 × 420px
- 선택한 스타일에 따라 실시간 반영
- 카드 내 구성:
  - 큰따옴표 아이콘 (상단)
  - 선택한 문장 텍스트 (중앙)
  - 책명 · 저자명 출처 (하단)
  - Bookmate 로고 워터마크 (카드 최하단)

#### 카드 스타일 옵션

| 스타일 | 배경색 | 텍스트색 |
|---|---|---|
| Green | `$accent` (#3D8A5A) | White |
| Coral | `$coral` (#D89575) | White |
| Dark | `#1A1918` | White |
| White | `#FFFFFF` | `$text-primary` |
| Blue | Blue 계열 | White |
| Photo | 사진 배경 + dark overlay | White |

- 색상 스와치 5개 + 사진 배경 썸네일 (총 6 옵션)
- 사진 배경 선택 시 → `jz2Vy` variant 화면으로 전환

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 스타일 스와치 탭 | 카드 배경 즉시 변경 | 현재 화면 내 |
| 사진 배경 스와치 탭 | 사진 배경 variant 전환 | `jz2Vy` |
| chevron-left 탭 | 이전 화면 | ← 4 문장 선택 |
| X (닫기) 탭 | 플로우 중단 | ← dismiss |
| "공유하기" 버튼 탭 | 공유 시트 열기 | → 5-2 공유 시트 |

#### 데이터

- **입력**: 선택된 문장 (String), Book 정보 (Book)
- **출력**: 카드 이미지 (UIImage, UIGraphicsImageRenderer로 렌더링), 선택된 CardStyle

---

### 4.8 공유 시트 (`xGLFA`)

| 항목 | 내용 |
|---|---|
| Screen ID | `xGLFA` |
| 화면명 | 5-2 공유 시트 |
| 크기 | 390 × 844px |
| 배경 | `#000000` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 완성된 카드를 외부로 공유 |
| 진입 조건 | 카드 꾸미기 → "공유하기" 탭 |
| 이전 화면 | 5 카드 꾸미기 |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `hUXt6` | H: 62 |
| Top Bar | `9KJLL` | H: 52, padding: [0,20], justifyContent: end — X(닫기) 아이콘 |
| Card Preview Area | `f9TdG` | fill_container, center 정렬, padding: [0,40] — 카드 전체화면 미리보기 |
| Share Sheet | `CSeAs` | cornerRadius: [24,24,0,0] (top only), fill: `#1E1E1E`, gap: 24, padding: [24,20,40,20] |

#### 공유 시트 (Bottom Sheet) 상세

| 옵션 | 아이콘 | 동작 |
|---|---|---|
| 링크 복사 | link | 카드 이미지 URL 클립보드 복사 |
| 인스타그램 | instagram | Instagram Stories/피드 공유 |
| 메시지 | message-circle | iMessage 공유 |
| 더보기 | more-horizontal | UIActivityViewController 열기 |
| 저장 | download | 카메라롤 저장 (PHPhotoLibrary) |

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 공유 옵션 아이콘 탭 | 해당 채널로 공유 실행 | 외부 앱/시스템 시트 |
| 저장 아이콘 탭 | 카메라롤 저장 | → 6 문장 수집 |
| X (닫기) 탭 | 공유 시트 닫기 | ← 5 카드 꾸미기 |

#### 데이터

- **입력**: 렌더링된 카드 이미지 (UIImage)
- **출력**: 공유 완료 여부, 카메라롤 저장 완료

#### 필수 권한

- `NSPhotoLibraryAddUsageDescription` — 카메라롤 저장 시

---

### 4.9 문장 수집 (`nzcgh`)

| 항목 | 내용 |
|---|---|
| Screen ID | `nzcgh` |
| 화면명 | 6 문장 수집 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 수집 문장에 메모, 태그를 붙여 저장 |
| 진입 조건 | 공유 시트에서 저장 완료 후 or T 버튼 (직접 입력) |
| 이전 화면 | 5-2 공유 시트 / 3-1 사진 촬영 (T 버튼) |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `KyGAs` | H: 62, padding: [22,20,0,20] |
| Header | `ZAkAD` | H: 52, padding: [0,20], space_between — BackHeader (chevron-left + "문장 수집" + X) |
| Content | `BL3DF` | fill_container, vertical, gap: 24, padding: [8,20,24,20] |

#### Content 영역 상세

1. **책 정보**: 커버 썸네일 (60 × 84px) + 책명 · 저자 · 페이지 정보
2. **나의 메모**: 80px 높이 텍스트 입력 영역 (placeholder: "이 문장에 대한 메모를 남겨보세요")
3. **인용문 섹션**: 스캔 CTA 배너 + 선택된 문장 텍스트 표시
4. **태그 섹션**: 기존 태그 chip 나열 + "태그 추가" 버튼
5. **하단 버튼**: SaveButton ("문장 저장하기")

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 메모 입력 | 텍스트 입력 | 현재 화면 내 |
| "태그 추가" 탭 | 태그 추가 Bottom Sheet 열기 | → 6-2 태그 추가 (overlay) |
| 기존 태그 chip 탭 | 해당 태그 제거 | 현재 화면 내 |
| chevron-left 탭 | 이전 화면 | ← pop |
| X (닫기) 탭 | 플로우 중단 | ← dismiss |
| "문장 저장하기" 탭 | 데이터 저장 | → 7 내 문장 |

#### 데이터

- **입력**: 문장 텍스트 (String), Book 정보 (Book), CardStyle
- **출력**: Quote 객체 생성 및 저장 { text, memo, tags[], book, pageNumber?, cardStyle, createdAt }

---

### 4.10 태그 추가 (`HHG5a`)

| 항목 | 내용 |
|---|---|
| Screen ID | `HHG5a` |
| 화면명 | 6-2 태그 추가 |
| 크기 | 390 × 844px |
| 배경 | `$bg` (하단에 Dimmed Overlay) |
| 레이아웃 | 수직 (vertical) |
| 목적 | 새 태그 입력 및 추천 태그 선택 |
| 진입 조건 | 문장 수집 화면에서 "태그 추가" 탭 |
| 이전 화면 | 6 문장 수집 (배경) |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `bt1OJ` | H: 62 |
| Header | `lcHEr` | H: 52 |
| Content | `PvOC4` | fill_container, vertical, gap: 24, padding: [8,20,24,20] |
| Dimmed Overlay | `6Ctkd` | 390 × 844, fill: `#00000066`, absolute (0,0) |

#### Dimmed Overlay 위 Bottom Sheet 구성

| 요소 | 설명 |
|---|---|
| Handle Bar | 시트 상단 드래그 핸들 |
| 헤더 | "태그 추가" 제목 + X(닫기) |
| 텍스트 입력 | 태그명 직접 입력 필드 |
| 추천 태그 목록 | 기본 제공 태그 chip 나열 (자아, 성장, 사랑, 위로 등) |
| "태그 추가" 버튼 | 확인 버튼 |

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 태그명 직접 입력 | 새 태그 생성 | 현재 시트 내 |
| 추천 태그 chip 탭 | 해당 태그 선택/해제 | 현재 시트 내 |
| "태그 추가" 버튼 탭 | 선택/입력된 태그 적용 | ← 6 문장 수집 (Sheet dismiss) |
| X (닫기) 탭 | 시트 닫기 (변경 취소) | ← 6 문장 수집 |
| Dimmed Overlay 탭 | 시트 닫기 | ← 6 문장 수집 |

#### 데이터

- **입력**: 현재 선택된 태그 배열 (Tag[])
- **출력**: 업데이트된 태그 배열 (Tag[])
- **추천 태그**: 앱 기본 제공 — 자아, 성장, 사랑, 위로 (확장 가능)

---

### 4.11 내 문장 (`jeZEu`)

| 항목 | 내용 |
|---|---|
| Screen ID | `jeZEu` |
| 화면명 | 7 내 문장 |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 저장된 모든 문장 목록 열람 및 태그 필터링 |
| 진입 조건 | 탭바 "내 문장" 탭 선택 / 문장 저장 완료 후 자동 전환 |
| 이전 화면 | — (탭 루트) |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `n53oK` | H: 62, padding: [22,20,0,20] |
| Header | `7YZE9` | H: 64, padding: [0,20], space_between — "내 문장" (Outfit 26/700) + 수집 개수 badge (`$accent`) + 검색 아이콘 |
| Filter Row | `7iU4B` | padding: [0,20], gap: 8, 수평 — FilterChip 나열 |
| Quote List | `iNYJn` | fill_container, vertical, padding: [16,20,0,20] — QuoteListItem 반복 |
| FAB | `uTEB2` | 56×56, absolute (314, 684) — 스캔 시작 |

#### Filter Row 상세

| 칩 | 기본 상태 |
|---|---|
| 전체 | Active (기본 선택) |
| 미지정 | Inactive |
| 자아 | Inactive |
| 성장 | Inactive |
| 사랑 | Inactive |
| 위로 | Inactive |

#### 사용자 인터랙션

| 액션 | 동작 | 이동 경로 |
|---|---|---|
| 필터 칩 탭 | 해당 태그 필터링 (복수 선택 가능) | 현재 화면 내 (→ 7-2 상태) |
| QuoteListItem 탭 | 문장 상세 보기 | 미설계 |
| 검색 아이콘 탭 | 문장 검색 | 미설계 |
| FAB 탭 | 스캔 플로우 시작 | → 2 도서 선택 (Modal) |

#### 데이터

- **입력**: 없음 (전체 Quote 목록 로드)
- **출력**: 필터링된 Quote 목록

---

### 4.12 태그 필터 (`EfqHN`)

| 항목 | 내용 |
|---|---|
| Screen ID | `EfqHN` |
| 화면명 | 7-2 태그 필터 (자아+성장) |
| 크기 | 390 × 844px |
| 배경 | `$bg` |
| 레이아웃 | 수직 (vertical) |
| 목적 | 복수 태그 동시 선택으로 문장 필터링 |
| 진입 조건 | 내 문장 화면에서 태그 칩 복수 선택 시 |
| 이전 화면 | 7 내 문장 (동일 화면의 상태 변화) |

#### UI 구성 요소

| 영역 | 노드 ID | 구조 |
|---|---|---|
| Status Bar | `Qwaxv` | H: 62, padding: [22,20,0,20] |
| Header | `9aAZ9` | H: 64, padding: [0,20], space_between |
| Filter Row | `QWfuF` | padding: [0,20], gap: 8 — 복수 선택된 칩 Active 표시 |
| Quote List | `aXqel` | fill_container, vertical, padding: [16,20,0,20] |
| FAB | `g25d8` | 56×56, absolute (314, 684) |

#### 필터링 로직

- 복수 태그 동시 선택 → **AND 조건** (두 태그 모두 포함된 문장만 노출)
- 예: "자아" + "성장" 선택 → 두 태그가 모두 있는 Quote만 표시
- "전체" 선택 시 → 모든 필터 해제, 전체 목록 표시
- "미지정" 선택 시 → 태그가 없는 Quote만 표시

#### 데이터

- **입력**: 선택된 태그 배열 (Tag[])
- **출력**: AND 조건 필터링된 Quote 목록

> **구현 참고**: 7 내 문장과 7-2 태그 필터는 동일한 ViewController에서 상태(state)로 관리. 별도 화면이 아닌 필터 상태 변화로 처리.

---

## 5. 데이터 모델

### 5.1 Book

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| id | ObjectId | O | Primary Key (자동 생성) |
| title | String | O | 책 제목 |
| author | String | O | 저자명 |
| isbn | String | O | ISBN |
| coverImageData | Data? | X | 표지 이미지 (로컬 바이너리 PNG) |
| coverImageURL | String | O | 표지 이미지 URL (Naver API, 원격 참조) |
| memo | String | O | 사용자 메모 (기본값 "") |
| createdAt | Date | O | 생성 일시 |
| quotes | LinkingObjects\<Quote\> | — | 역관계 (이 책에 연결된 문장 목록) |

### 5.1-2 SearchedBook (검색 기록)

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| id | ObjectId | O | Primary Key (자동 생성) |
| title | String | O | 책 제목 |
| author | String | O | 저자명 |
| isbn | String | O | ISBN |
| coverImageURL | String | O | 표지 이미지 URL (Naver API) |
| searchedAt | Date | O | 마지막 검색 일시 |

> **Note**: Book과 SearchedBook은 분리된 테이블. SearchedBook은 검색 기록용이며, Book은 문장이 수집된 도서 정보를 저장한다. ISBN으로 매칭하여 중복을 방지한다.

### 5.2 Quote

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| id | ObjectId | O | Primary Key (자동 생성) |
| text | String | O | 수집된 문장 |
| memo | String? | X | 사용자 메모 |
| pageNumber | Int? | X | 페이지 번호 |
| createdAt | Date | O | 생성 일시 |
| cardStyle | CardStyle? | O | 카드 스타일 (임베디드) |
| book | Book? | O | 출처 도서 (N:1 관계) |
| tags | List\<Tag\> | X | 연결된 태그 (N:N 관계) |

### 5.3 Tag

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| id | ObjectId | O | Primary Key (자동 생성) |
| name | String | O | 태그명 (자아, 성장, 사랑, 위로 등) |
| quotes | LinkingObjects\<Quote\> | — | 역관계 (이 태그가 연결된 문장 목록) |

### 5.4 CardStyle

| 필드 | 타입 | 설명 |
|---|---|---|
| type | Enum | green / coral / dark / white / blue / photo |

### 5.5 관계 (Relationships)

```
Book (1) ←→ (N) Quote
Quote (N) ←→ (N) Tag
Quote (1) → (1) CardStyle (embedded)
```

---

## 6. 네비게이션 구조

### 6.1 탭 구조

```
UITabBarController (커스텀 Pill TabBar)
├── Tab 0: 홈 (UINavigationController)
│   └── HomeViewController
│       └── QuoteDetailViewController (미설계)
├── Tab 1: 수집 (중앙 버튼) → Modal 스캔 플로우 트리거
└── Tab 2: 내 문장 (UINavigationController)
    └── MyQuotesViewController (7 내 문장 + 7-2 태그 필터)
        └── QuoteDetailViewController (미설계)
```

### 6.2 Modal 스캔 플로우

```
UINavigationController (Modal, fullScreen)
└── BookSelectionViewController (2 도서 선택)
    └── BookDetailViewController (도서 상세 — 메모, 수집된 문장 목록)
        └── AddQuoteSheetViewController (문장 추가 방식 선택 Bottom Sheet)
            ├── CameraCaptureViewController (3-1 사진 촬영)
            │   └── PhotoReviewViewController (3-2 사진 확인)
            │       └── TextRecognitionViewController (3-3 텍스트 인식/OCR)
            │           └── SentenceSelectionViewController (4 문장 선택)
            │               └── DetailSheetViewController (페이지/태그 입력 Bottom Sheet)
            └── ManualQuoteEntryViewController (텍스트 직접 입력)
                └── DetailSheetViewController (페이지/태그 입력 Bottom Sheet)
```

> **현재 상태**: SceneDelegate에서 BookDetailViewController가 루트로 하드코딩되어 있음 (개발 stub). 탭바 네비게이션 미구현.

### 6.3 전환 방식

| 전환 | 방식 |
|---|---|
| 탭 간 이동 | UITabBarController 내부 전환 |
| 스캔 플로우 진입 | `present(_:animated:)` — fullScreen modal |
| 스캔 플로우 내 화면 | `pushViewController(_:animated:)` — Navigation push |
| 태그 추가 | `presentAsBottomSheet()` — Bottom Sheet (dimmed overlay) |
| 공유 시트 | 커스텀 Bottom Sheet (in-app) |
| 플로우 종료 | `dismiss(animated:)` — 탭 화면으로 복귀 |

---

## 7. 필수 프레임워크 및 권한

### 7.1 프레임워크 및 라이브러리

| 프레임워크/라이브러리 | 용도 |
|---|---|
| UIKit | 전체 UI 구성 |
| SnapKit | Auto Layout DSL |
| RxSwift / RxCocoa | 반응형 프로그래밍 및 UIKit 바인딩 |
| Alamofire | HTTP 네트워킹 (Naver Books API) |
| Kingfisher | 이미지 로딩 및 캐싱 |
| RealmSwift | 로컬 데이터 영속화 |
| AVFoundation | 카메라 세션 관리 (AVCaptureSession) |
| Vision | OCR 텍스트 인식 (VNRecognizeTextRequest) |
| Photos / PhotosUI | 갤러리 접근 및 카메라롤 저장 |

### 7.2 Info.plist 권한

| Key | 설명 | 요청 시점 |
|---|---|---|
| `NSCameraUsageDescription` | 책 페이지 촬영을 위해 카메라를 사용합니다 | 3-1 사진 촬영 진입 시 |
| `NSPhotoLibraryUsageDescription` | 갤러리에서 사진을 선택하기 위해 접근합니다 | 3-1 갤러리 버튼 탭 시 |
| `NSPhotoLibraryAddUsageDescription` | 카드 이미지를 카메라롤에 저장합니다 | 5-2 저장 탭 시 |

---

## 8. 미설계 영역 (추후 기획 필요)

| 영역 | 설명 |
|---|---|
| 문장 상세 보기 | QuoteListItem 탭 시 진입하는 상세 화면 |
| 알림 기능 | 홈 헤더 벨 아이콘 → 알림 목록 |
| 큐레이션 관리 | 홈 피드의 큐레이션 콘텐츠 관리 로직 |
| 검색 결과 | 내 문장 화면의 검색 기능 상세 |
| 온보딩 / 권한 요청 | 최초 실행 시 카메라/사진 권한 안내 |
| 설정 화면 | 테마 변경, 계정 정보 등 |
| 홈 화면 데이터 바인딩 | 레이아웃만 완성, 오늘의 문장/큐레이션 데이터 미연결 |
| 탭바 네비게이션 | TabBarView 컴포넌트 존재, UITabBarController 연결 미구현 |
| 내 문장 목록 화면 | MyQuotesViewController 미구현 |
| 카드 꾸미기 / 공유 시트 | UI 스펙만 존재, ViewController 미구현 |
| ~~도서 검색 API~~ | ~~구현 완료~~ — Naver Books API 연동 (NaverBookService, BookSearchModels), Secrets.xcconfig으로 크레덴셜 관리 |
| ~~책 상세 / 책별 목록~~ | ~~구현 완료~~ — BookDetailViewController (메모 입력, 수집 문장 목록, AddQuoteSheet 진입) |
| ~~텍스트 직접 입력~~ | ~~구현 완료~~ — ManualQuoteEntryViewController (카메라 없이 문장 직접 입력) |

### 8.1 구현 완료 화면 (스펙 신규 반영)

| 화면 | ViewController | 설명 |
|---|---|---|
| 도서 선택 | BookSelectionViewController | Naver API 검색, 페이지네이션, 최근 검색 도서 |
| 도서 상세 | BookDetailViewController | 책 정보, 메모 입력, 수집 문장 목록, 문장 추가 진입 |
| 문장 추가 방식 선택 | AddQuoteSheetViewController | Bottom Sheet — 카메라 촬영 / 직접 입력 선택 |
| 사진 촬영 | CameraCaptureViewController | AVFoundation 카메라, 셔터, 플래시 토글 |
| 사진 확인 | PhotoReviewViewController | 촬영 이미지 확인, 다시 촬영 / 텍스트 인식 선택 |
| 텍스트 인식 | TextRecognitionViewController | Vision OCR, 언어/정확도 설정 |
| 문장 선택 | SentenceSelectionViewController | OCR 결과에서 최대 3줄 연속 선택 |
| 텍스트 직접 입력 | ManualQuoteEntryViewController | 카메라 없이 문장 수동 입력 |
| 페이지/태그 입력 | DetailSheetViewController | Bottom Sheet — 페이지 번호, 태그 추가 (추천 태그: 사랑, 위로, 용기, 인생, 지혜, 철학, 감성) |

### 8.2 Info.plist 권한 현황

| Key | 스펙 | 코드 (Info.plist) | 상태 |
|---|---|---|---|
| `NSCameraUsageDescription` | 필요 | 등록됨 | ✅ |
| `NSPhotoLibraryUsageDescription` | 필요 | **미등록** | ⚠️ 추가 필요 |
| `NSPhotoLibraryAddUsageDescription` | 필요 | **미등록** | ⚠️ 추가 필요 |
