import XCTest
@testable import Bookmate

final class BookSearchModelsTests: XCTestCase {

    // MARK: - cleanTitle

    func test_cleanTitle_removesHTMLBoldTags() {
        let item = makeItem(title: "<b>Swift</b> Programming")
        XCTAssertEqual(item.cleanTitle, "Swift Programming")
    }

    func test_cleanTitle_removesMultipleHTMLTags() {
        let item = makeItem(title: "<b>Hello</b> <i>World</i>")
        XCTAssertEqual(item.cleanTitle, "Hello World")
    }

    func test_cleanTitle_noTagsReturnsOriginal() {
        let item = makeItem(title: "No Tags Here")
        XCTAssertEqual(item.cleanTitle, "No Tags Here")
    }

    // MARK: - authors

    func test_authors_splitsByCaret() {
        let item = makeItem(author: "Author A^Author B^Author C")
        XCTAssertEqual(item.authors, ["Author A", "Author B", "Author C"])
    }

    func test_authors_singleAuthor() {
        let item = makeItem(author: "Solo Author")
        XCTAssertEqual(item.authors, ["Solo Author"])
    }

    // MARK: - publishedDate

    func test_publishedDate_validFormat() {
        let item = makeItem(pubdate: "20240315")
        let date = item.publishedDate

        XCTAssertNotNil(date)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: date!), 2024)
        XCTAssertEqual(calendar.component(.month, from: date!), 3)
        XCTAssertEqual(calendar.component(.day, from: date!), 15)
    }

    func test_publishedDate_invalidFormat_returnsNil() {
        let item = makeItem(pubdate: "invalid")
        XCTAssertNil(item.publishedDate)
    }

    // MARK: - Helpers

    private func makeItem(
        title: String = "Title",
        author: String = "Author",
        pubdate: String = "20240101"
    ) -> BookItem {
        BookItem(
            title: title,
            link: "https://example.com",
            image: "https://example.com/img.jpg",
            author: author,
            discount: nil,
            publisher: "Publisher",
            isbn: "1234567890",
            description: "Desc",
            pubdate: pubdate
        )
    }
}
