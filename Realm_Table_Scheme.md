# Bookmate — Realm Database Schema

> Realm Swift 기반 로컬 데이터 모델 정의

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| ORM | Realm Swift (RealmSwift) |
| 주요 테이블 | Book, SearchedBook, Quote, Tag |
| 임베디드 객체 | CardStyle |
| 관계 | Book ↔ Quote (1:N), Quote ↔ Tag (N:N) |
| 스키마 버전 | 5 |

---

## 2. 테이블 정의

### 2.1 Book

책 정보를 저장하는 테이블.

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `id` | `ObjectId` | O | 자동 생성 | Primary Key |
| `title` | `String` | O | — | 책 제목 |
| `author` | `String` | O | — | 저자명 |
| `isbn` | `String` | O | — | ISBN |
| `coverImageData` | `Data?` | X | `nil` | 표지 이미지 (로컬 바이너리 PNG) |
| `coverImageURL` | `String` | O | `""` | 표지 이미지 URL (Naver API, 원격 참조) |
| `memo` | `String` | O | `""` | 사용자 메모 |
| `createdAt` | `Date` | O | `Date()` | 생성 일시 |

**역관계 (Inverse Relationship):**

| 필드명 | 타입 | 설명 |
|---|---|---|
| `quotes` | `LinkingObjects<Quote>` | 이 책에 연결된 문장 목록 (역참조) |

```swift
class Book: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var author: String = ""
    @Persisted var isbn: String = ""
    @Persisted var coverImageData: Data?
    @Persisted var coverImageURL: String = ""
    @Persisted var memo: String = ""
    @Persisted var createdAt: Date = Date()

    // Inverse relationship
    @Persisted(originProperty: "book") var quotes: LinkingObjects<Quote>
}
```

---

### 2.1-2 SearchedBook (검색 기록)

도서 검색 기록을 저장하는 테이블. Book 테이블과 분리하여 검색 이력과 수집 도서를 독립 관리.

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `id` | `ObjectId` | O | 자동 생성 | Primary Key |
| `title` | `String` | O | — | 책 제목 |
| `author` | `String` | O | — | 저자명 |
| `isbn` | `String` | O | — | ISBN |
| `coverImageURL` | `String` | O | — | 표지 이미지 URL (Naver API) |
| `searchedAt` | `Date` | O | `Date()` | 마지막 검색 일시 |

```swift
class SearchedBook: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var author: String
    @Persisted var isbn: String
    @Persisted var coverImageURL: String
    @Persisted var searchedAt: Date = Date()
}
```

> **Book vs SearchedBook**: SearchedBook은 Naver API 검색 결과의 이력을 저장하며, coverImageURL로 원격 이미지를 참조한다. Book은 실제 문장이 수집된 도서의 정보를 저장하며, coverImageData로 이미지를 로컬 바이너리로 캐싱한다. ISBN으로 매칭하여 중복을 방지한다.

---

### 2.2 Quote

수집된 문장을 저장하는 테이블. 앱의 핵심 데이터.

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `id` | `ObjectId` | O | 자동 생성 | Primary Key |
| `text` | `String` | O | — | 수집된 문장 텍스트 |
| `memo` | `String?` | X | `nil` | 사용자 메모 |
| `pageNumber` | `Int?` | X | `nil` | 페이지 번호 |
| `createdAt` | `Date` | O | `Date()` | 생성 일시 |
| `cardStyle` | `CardStyle?` | O | — | 카드 스타일 (임베디드) |
| `book` | `Book?` | O | — | 출처 도서 (N:1 관계) |
| `tags` | `List<Tag>` | X | 빈 리스트 | 연결된 태그 (N:N 관계) |

```swift
class Quote: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var text: String
    @Persisted var memo: String?
    @Persisted var pageNumber: Int?
    @Persisted var createdAt: Date = Date()
    @Persisted var cardStyle: CardStyle?
    @Persisted var book: Book?
    @Persisted var tags: List<Tag>
}
```

---

### 2.3 Tag

문장에 부여하는 태그 테이블.

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `id` | `ObjectId` | O | 자동 생성 | Primary Key |
| `name` | `String` | O | — | 태그명 (예: 자아, 성장, 사랑, 위로) |

**역관계 (Inverse Relationship):**

| 필드명 | 타입 | 설명 |
|---|---|---|
| `quotes` | `LinkingObjects<Quote>` | 이 태그가 연결된 문장 목록 (역참조) |

```swift
class Tag: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String

    // Inverse relationship
    @Persisted(originProperty: "tags") var quotes: LinkingObjects<Quote>
}
```

---

### 2.4 CardStyle (EmbeddedObject)

카드 꾸미기 스타일 정보. Quote에 임베디드로 저장.

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `type` | `String` | O | `"green"` | 카드 스타일 타입 |

**CardStyle.type 열거값:**

| 값 | 배경색 | 텍스트색 | 설명 |
|---|---|---|---|
| `green` | `#3D8A5A` | White | 기본 accent 색상 |
| `coral` | `#D89575` | White | 보조 coral 색상 |
| `dark` | `#1A1918` | White | 다크 배경 |
| `white` | `#FFFFFF` | `#1A1918` | 화이트 배경 |
| `blue` | Blue 계열 | White | 블루 배경 |
| `photo` | 사진 배경 | White | 사진 + 오버레이 |

```swift
class CardStyle: EmbeddedObject {
    @Persisted var type: String = CardStyleType.green.rawValue
}

enum CardStyleType: String, CaseIterable {
    case green
    case coral
    case dark
    case white
    case blue
    case photo
}
```

---

## 3. 관계 다이어그램 (ERD)

```
┌──────────────┐
│ SearchedBook │  (검색 기록, 독립 테이블)
├──────────────┤
│ id (PK)      │
│ title        │
│ author       │
│ isbn         │
│ coverImageURL│
│ searchedAt   │
└──────────────┘

┌──────────┐       1:N       ┌──────────┐       N:N       ┌──────────┐
│   Book   │────────────────▶│  Quote   │◀──────────────▶│   Tag    │
├──────────┤                 ├──────────┤                 ├──────────┤
│ id (PK)  │                 │ id (PK)  │                 │ id (PK)  │
│ title    │                 │ text     │                 │ name     │
│ author   │                 │ memo     │                 └──────────┘
│ isbn     │                 │ pageNum  │
│ coverData│                 │ createdAt│
│ coverURL │                 │ cardStyle│ ◀── EmbeddedObject
│ memo     │                 │ book ──▶ │      ┌───────────┐
│ createdAt│                 │ tags ──▶ │      │ CardStyle │
└──────────┘                 └──────────┘      ├───────────┤
                                               │ type      │
                                               └───────────┘
```

---

## 4. 기본 제공 데이터 (Seed Data)

### 기본 태그

앱 초기 실행 시 아래 태그를 자동 생성:

| name |
|---|
| 자아 |
| 성장 |
| 사랑 |
| 위로 |

```swift
func seedDefaultTags(realm: Realm) {
    let defaultTagNames = ["자아", "성장", "사랑", "위로"]
    try? realm.write {
        for name in defaultTagNames {
            if realm.objects(Tag.self).filter("name == %@", name).isEmpty {
                let tag = Tag()
                tag.name = name
                realm.add(tag)
            }
        }
    }
}
```

---

## 5. 주요 쿼리 패턴

### 5.1 전체 문장 조회 (최신순)

```swift
realm.objects(Quote.self).sorted(byKeyPath: "createdAt", ascending: false)
```

### 5.2 태그 필터링 (AND 조건)

```swift
// "자아" + "성장" 태그 모두 포함된 문장
realm.objects(Quote.self)
    .filter("ANY tags.name == %@ AND ANY tags.name == %@", "자아", "성장")
```

### 5.3 미지정 태그 문장 조회

```swift
realm.objects(Quote.self).filter("tags.@count == 0")
```

### 5.4 특정 책의 문장 조회

```swift
realm.objects(Quote.self)
    .filter("book.id == %@", bookId)
    .sorted(byKeyPath: "createdAt", ascending: false)
```

### 5.5 도서 검색

```swift
realm.objects(Book.self)
    .filter("title CONTAINS[c] %@ OR author CONTAINS[c] %@", keyword, keyword)
```

### 5.6 최근 검색 도서 (SearchedBook, 최신순)

```swift
realm.objects(SearchedBook.self)
    .sorted(byKeyPath: "searchedAt", ascending: false)
```

### 5.7 문장이 있는 도서 (최신순)

```swift
realm.objects(Book.self)
    .filter("quotes.@count > 0")
    .sorted(byKeyPath: "createdAt", ascending: false)
```

### 5.8 ISBN으로 도서 조회

```swift
realm.objects(Book.self).filter("isbn == %@", isbn).first
```

---

## 6. Realm 설정

```swift
let config = Realm.Configuration(
    schemaVersion: 5,
    migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 2 {
            // v1→v2: Book에 lastSearchedAt 추가
        }
        if oldSchemaVersion < 3 {
            // v2→v3: lastSearchedAt: Date → Date?
        }
        if oldSchemaVersion < 4 {
            // v3→v4: Book.lastSearchedAt 제거, SearchedBook 테이블 생성
            // 기존 Book.lastSearchedAt 데이터를 SearchedBook으로 마이그레이션
            migration.enumerateObjects(ofType: Book.className()) { oldObject, newObject in
                if let lastSearchedAt = oldObject?["lastSearchedAt"] as? Date {
                    let searchedBook = migration.create(SearchedBook.className())
                    searchedBook["title"] = oldObject?["title"]
                    searchedBook["author"] = oldObject?["author"]
                    searchedBook["isbn"] = oldObject?["isbn"] ?? ""
                    searchedBook["coverImageURL"] = ""
                    searchedBook["searchedAt"] = lastSearchedAt
                }
            }
        }
        if oldSchemaVersion < 5 {
            // v4→v5: Book에 coverImageURL, memo 추가 — Realm이 자동 처리 (기본값 "")
        }
    },
    objectTypes: [Book.self, SearchedBook.self, Quote.self, Tag.self, CardStyle.self]
)
Realm.Configuration.defaultConfiguration = config
```

> **⚠️ 현재 상태**: 코드에서 마이그레이션 블록이 주석 처리되어 있고 `Realm.Configuration.defaultConfiguration`을 그대로 사용 중. 프로덕션 배포 전 반드시 마이그레이션 블록을 활성화해야 함.
