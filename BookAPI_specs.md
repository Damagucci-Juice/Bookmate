# Naver Books Search API Specification

Bookmate 앱의 도서 검색에 사용하는 네이버 책 검색 API 명세서.

## Overview

네이버 검색의 책 검색 결과를 XML 또는 JSON 형식으로 반환한다.

## Authentication

HTTP 요청 헤더에 클라이언트 아이디와 시크릿을 포함해야 한다.

| Header | Description |
|---|---|
| `X-Naver-Client-Id` | 애플리케이션 등록 시 발급받은 클라이언트 아이디 |
| `X-Naver-Client-Secret` | 애플리케이션 등록 시 발급받은 클라이언트 시크릿 |

> **Note**: 크레덴셜은 소스 코드에 하드코딩하지 말 것. `Info.plist` 또는 `.xcconfig`를 통해 주입하고, `.gitignore`에 추가할 것.

## Endpoints

| URL | Response Format |
|---|---|
| `https://openapi.naver.com/v1/search/book.json` | JSON |
| `https://openapi.naver.com/v1/search/book.xml` | XML |

- **Protocol**: HTTPS
- **Method**: GET

## Request Parameters

Query string으로 전달한다.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `query` | String | Y | 검색어. UTF-8로 인코딩되어야 한다. |
| `display` | Integer | N | 한 번에 표시할 검색 결과 개수 (기본값: 10, 최댓값: 100) |
| `start` | Integer | N | 검색 시작 위치 (기본값: 1, 최댓값: 1000) |
| `sort` | String | N | 검색 결과 정렬 방법. `sim`: 정확도순 내림차순 (기본값), `date`: 출간일순 내림차순 |

## Request Example

```bash
curl "https://openapi.naver.com/v1/search/book.json?query=%EC%A7%80%EB%8F%84&display=10&start=1" \
  -H "X-Naver-Client-Id: {CLIENT_ID}" \
  -H "X-Naver-Client-Secret: {CLIENT_SECRET}"
```

## Response (JSON)

### Top-level Fields

| Field | Type | Description |
|---|---|---|
| `lastBuildDate` | String (datetime) | 검색 결과를 생성한 시간 |
| `total` | Integer | 총 검색 결과 개수 |
| `start` | Integer | 검색 시작 위치 |
| `display` | Integer | 한 번에 표시할 검색 결과 개수 |
| `items` | Array\<BookItem\> | 개별 검색 결과 배열 |

### BookItem Fields

| Field | Type | Description |
|---|---|---|
| `title` | String | 책 제목 (HTML 태그 `<b>` 포함 가능) |
| `link` | String | 네이버 도서 정보 URL |
| `image` | String | 섬네일 이미지 URL |
| `author` | String | 저자 이름 (복수 저자는 `^`로 구분) |
| `discount` | String | 판매 가격 (절판 등의 이유로 가격이 없으면 빈 문자열) |
| `publisher` | String | 출판사 |
| `isbn` | String | ISBN |
| `description` | String | 네이버 도서의 책 소개 |
| `pubdate` | String | 출간일 (`YYYYMMDD` 형식) |

### Response Example

```json
{
  "lastBuildDate": "Fri, 20 Mar 2026 14:52:17 +0900",
  "total": 6216,
  "start": 1,
  "display": 10,
  "items": [
    {
      "title": "에이든 도쿄 여행지도(2026-2027)",
      "link": "https://search.shopping.naver.com/book/catalog/57558743250",
      "image": "https://shopping-phinf.pstatic.net/main_5755874/57558743250.20251106083923.jpg",
      "author": "타블라라사 편집부^이정기",
      "discount": "17820",
      "publisher": "타블라라사",
      "pubdate": "20251104",
      "isbn": "9791190073882",
      "description": "일본여행 베스트셀러 에이든 도쿄 여행지도가..."
    }
  ]
}
```

## Error Codes

| Error Code | HTTP Status | Message | Description |
|---|---|---|---|
| SE01 | 400 | Incorrect query request | API 요청 URL의 프로토콜, 파라미터 등에 오류 확인 |
| SE02 | 400 | Invalid display value | `display` 값이 허용 범위(1~100)인지 확인 |
| SE03 | 400 | Invalid start value | `start` 값이 허용 범위(1~1000)인지 확인 |
| SE04 | 400 | Invalid sort value | `sort` 파라미터 값에 오타가 있는지 확인 |
| SE06 | 400 | Malformed encoding | 검색어를 UTF-8로 인코딩 |
| SE05 | 404 | Invalid search api | API 요청 URL에 오타가 있는지 확인 |
| SE99 | 500 | System Error | 서버 내부 오류. 네이버 개발자 포럼에 오류 신고 |

### 403 Error

개발자 센터에 등록한 애플리케이션에서 검색 API를 사용하도록 설정하지 않았다면 403 오류가 발생한다. 네이버 개발자 센터 > Application > 내 애플리케이션 > API 설정 탭에서 '검색'이 선택되어 있는지 확인할 것.

## iOS Integration Notes

### Alamofire Usage

```swift
import Alamofire

struct NaverBookAPI {
    static let baseURL = "https://openapi.naver.com/v1/search/book.json"

    static var headers: HTTPHeaders {
        [
            "X-Naver-Client-Id": Bundle.main.naverClientId,
            "X-Naver-Client-Secret": Bundle.main.naverClientSecret
        ]
    }

    static func search(query: String, display: Int = 10, start: Int = 1, sort: String = "sim") -> DataRequest {
        let parameters: Parameters = [
            "query": query,
            "display": display,
            "start": start,
            "sort": sort
        ]
        return AF.request(baseURL, method: .get, parameters: parameters, headers: headers)
    }
}
```

### Decodable Model

```swift
struct BookSearchResponse: Decodable {
    let lastBuildDate: String
    let total: Int
    let start: Int
    let display: Int
    let items: [BookItem]
}

struct BookItem: Decodable {
    let title: String
    let link: String
    let image: String
    let author: String
    let discount: String?
    let publisher: String
    let isbn: String
    let description: String
    let pubdate: String
}
```

### Parsing Notes

- `title`에 HTML `<b>` 태그가 포함될 수 있으므로, 표시 전에 태그를 제거하거나 NSAttributedString으로 변환할 것.
- `author`의 복수 저자는 `^` 구분자로 연결되어 있으므로 `split(separator: "^")`로 파싱.
- `discount`는 절판 시 빈 값이므로 옵셔널로 처리.
- `pubdate`는 `YYYYMMDD` 형식의 문자열이므로 `DateFormatter`로 파싱 시 `"yyyyMMdd"` 포맷 사용.
