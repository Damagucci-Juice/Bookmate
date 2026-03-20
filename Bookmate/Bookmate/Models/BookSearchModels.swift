import Foundation

// MARK: - Response

struct BookSearchResponse: Decodable {
    let lastBuildDate: String
    let total: Int
    let start: Int
    let display: Int
    let items: [BookItem]
}

// MARK: - BookItem

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

    // HTML <b> 태그 제거된 순수 제목
    var cleanTitle: String {
        title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }

    // "^" 구분자로 분리된 저자 배열
    var authors: [String] {
        author.split(separator: "^").map(String.init)
    }

    // "YYYYMMDD" → Date
    var publishedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: pubdate)
    }
}

// MARK: - Error Response

struct NaverAPIError: Decodable {
    let errorCode: String
    let errorMessage: String
}
