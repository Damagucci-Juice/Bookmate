import XCTest
import RealmSwift
@testable import Bookmate

final class BookRepositoryTests: XCTestCase {

    private var realm: Realm!
    private var sut: BookRepository!

    override func setUp() {
        super.setUp()
        realm = TestRealmHelper.makeInMemoryRealm()
        sut = BookRepository(realm: realm)
    }

    override func tearDown() {
        sut = nil
        realm = nil
        super.tearDown()
    }

    // MARK: - findOrCreate

    func test_findOrCreate_createsNewBook() {
        let item = makeBookItem(isbn: "1234567890")

        let book = sut.findOrCreate(from: item)

        XCTAssertEqual(realm.objects(Book.self).count, 1)
        XCTAssertEqual(book.isbn, "1234567890")
        XCTAssertEqual(book.title, "Test Title")
        XCTAssertEqual(book.author, "Author A")
    }

    func test_findOrCreate_returnsSameBookForDuplicateISBN() {
        let item = makeBookItem(isbn: "1234567890")

        let first = sut.findOrCreate(from: item)
        let second = sut.findOrCreate(from: item)

        XCTAssertEqual(realm.objects(Book.self).count, 1)
        XCTAssertEqual(first.id, second.id)
    }

    // MARK: - fetch

    func test_fetch_returnsBookById() {
        let item = makeBookItem(isbn: "111")
        let created = sut.findOrCreate(from: item)

        let fetched = sut.fetch(id: created.id)

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.isbn, "111")
    }

    // MARK: - delete

    func test_delete_removesBookButKeepsQuotes() {
        let book = sut.findOrCreate(from: makeBookItem(isbn: "999"))
        let quote = Quote()
        quote.text = "Some quote"
        quote.book = book
        try! realm.write { realm.add(quote) }

        sut.delete(book)

        XCTAssertEqual(realm.objects(Book.self).count, 0)
        XCTAssertEqual(realm.objects(Quote.self).count, 1)
        let remainingQuote = realm.objects(Quote.self).first!
        XCTAssertNil(remainingQuote.book)
    }

    // MARK: - SearchedBook

    func test_addToSearchHistory_createsSearchedBook() {
        let item = makeBookItem(isbn: "555")

        let searched = sut.addToSearchHistory(from: item)

        XCTAssertEqual(realm.objects(SearchedBook.self).count, 1)
        XCTAssertEqual(searched.isbn, "555")
    }

    func test_addToSearchHistory_updatesTimestampForDuplicate() {
        let item = makeBookItem(isbn: "555")

        let first = sut.addToSearchHistory(from: item)
        let firstDate = first.searchedAt

        // 약간의 시간차
        Thread.sleep(forTimeInterval: 0.01)
        let second = sut.addToSearchHistory(from: item)

        XCTAssertEqual(realm.objects(SearchedBook.self).count, 1)
        XCTAssertEqual(first.id, second.id)
        XCTAssertGreaterThan(second.searchedAt, firstDate)
    }

    func test_clearRecentSearches_deletesAll() {
        sut.addToSearchHistory(from: makeBookItem(isbn: "1"))
        sut.addToSearchHistory(from: makeBookItem(isbn: "2"))
        XCTAssertEqual(realm.objects(SearchedBook.self).count, 2)

        sut.clearRecentSearches()

        XCTAssertEqual(realm.objects(SearchedBook.self).count, 0)
    }

    // MARK: - Helpers

    private func makeBookItem(isbn: String) -> BookItem {
        BookItem(
            title: "Test Title",
            link: "https://example.com",
            image: "https://example.com/cover.jpg",
            author: "Author A",
            discount: nil,
            publisher: "Publisher",
            isbn: isbn,
            description: "A test book",
            pubdate: "20240101"
        )
    }
}
