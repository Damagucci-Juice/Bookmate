# Bookmate

**맞춤형 독서 기록 및 공유 앱** - 책 속 문장을 촬영하고, 카드로 꾸미고, 나만의 컬렉션으로 정리하세요.

> **개발 기간**: 2025.03.17 ~ 2025.03.31 (2주)

## Screenshots

<p align="center">
  <img src="images/Apple iPhone 16 Pro Max Screenshot 1.png" width="180" alt="내 문장을 내 곁에" />
  <img src="images/Apple iPhone 16 Pro Max Screenshot 2.png" width="180" alt="사진 촬영으로 손 쉬운 수집" />
  <img src="images/Apple iPhone 16 Pro Max Screenshot 3.png" width="180" alt="원하는 문장만 골라 담기" />
  <img src="images/Apple iPhone 16 Pro Max Screenshot 4.png" width="180" alt="마음 가는 대로 카드를 꾸미기" />
</p>
<p align="center">
  <img src="images/Apple iPhone 16 Pro Max Screenshot 5.png" width="180" alt="찾고자 하는 책을 검색" />
  <img src="images/Apple iPhone 16 Pro Max Screenshot 6.png" width="180" alt="손으로 적거나 카메라로 찍거나" />
  <img src="images/Apple iPhone 16 Pro Max Screenshot 7.png" width="180" alt="수정과 삭제도 간편하게" />
</p>

## Features

- **카메라 OCR** - 책 페이지를 촬영하면 Vision 프레임워크가 텍스트를 자동 인식
- **도서 검색** - Naver Books API로 책을 검색하고 인용구와 연결
- **카드 꾸미기** - 수집한 문장을 다양한 스타일의 카드로 꾸미고 공유
- **태그 & 컬렉션** - 태그를 붙여 문장을 체계적으로 정리하고 필터링
- **다크 모드** - 라이트/다크 테마 지원

## User Flow

```
홈 → 도서 선택 → 사진 촬영 → 사진 확인 → 텍스트 인식(OCR)
  → 문장 선택 → 카드 꾸미기 → 공유 / 저장
  → 문장 수집 → 태그 추가
  → 내 문장 목록 → 태그 필터
```

## Tech Stack

| 영역 | 기술 |
|---|---|
| UI Framework | UIKit (코드 기반) |
| Layout | SnapKit |
| Reactive | RxSwift / RxCocoa |
| Networking | Alamofire |
| Image Loading | Kingfisher |
| Database | RealmSwift |
| OCR | Vision Framework |
| Book API | Naver Books API |
| Package Manager | Swift Package Manager |

## Project Structure

```
Bookmate/
├── Bookmate/                    # Xcode 프로젝트
│   └── Bookmate/
│       ├── DesignSystem/         # AppColor, AppFont, AppIcon
│       ├── Models/              # Realm 모델, API 응답 모델
│       ├── Services/            # Naver API, OCR, Realm 설정
│       ├── Repositories/        # Book/Quote CRUD
│       └── Screens/             # 화면별 ViewController
│           ├── Home/
│           ├── Book/
│           ├── Capture/
│           ├── Quote/
│           └── Components/
├── Bookmate.pen                 # Pencil 디자인 파일
├── images/                      # 스크린샷 및 디자인 미리보기
├── Functional_Specs.md          # 기능정의서
├── Design_Specs.md              # 디자인정의서
├── BookAPI_specs.md             # Naver Books API 명세
├── AppPlaning.md                # 앱 기획 문서
└── Realm_Table_Scheme.md        # Realm DB 스키마
```

## Getting Started

### 요구사항

- Xcode 16+
- iOS 18.0+
- Swift 5.0

### 설치

1. 레포지토리 클론
   ```bash
   git clone https://github.com/Damagucci-Juice/Bookmate.git
   cd Bookmate
   ```

2. Naver API 키 설정 - `Bookmate/Bookmate/Secrets.xcconfig` 파일 생성:
   ```
   NAVER_CLIENT_ID = your_client_id
   NAVER_CLIENT_SECRET = your_client_secret
   ```
   > [Naver Developers](https://developers.naver.com)에서 검색 API 키를 발급받으세요.

3. Xcode에서 `Bookmate/Bookmate.xcodeproj` 열기

4. SPM 의존성이 자동으로 resolve됩니다. 빌드 후 실행하세요.

## Implementation Status

### 구현 완료

- 도서 선택 화면 (Naver API 검색, 페이지네이션, 최근 검색)
- Realm 데이터 모델 (Book, SearchedBook, Quote, Tag, CardStyle)
- Repository 계층 (BookRepository, QuoteRepository)
- 색상/폰트/아이콘 디자인 시스템

### 진행 중

- 홈 화면 데이터 바인딩
- 카메라/OCR 촬영 화면
- 문장 선택 및 카드 꾸미기
- 태그 관리 및 내 문장 목록
- 탭바 네비게이션

## Documents

- [기능정의서](Functional_Specs.md)
- [디자인정의서](Design_Specs.md)
- [Naver Books API 명세](BookAPI_specs.md)
- [앱 기획 문서](AppPlaning.md)
- [Realm DB 스키마](Realm_Table_Scheme.md)
