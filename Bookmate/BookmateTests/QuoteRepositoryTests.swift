import XCTest
import RealmSwift
@testable import Bookmate

final class QuoteRepositoryTests: XCTestCase {

    private var realm: Realm!
    private var sut: QuoteRepository!

    override func setUp() {
        super.setUp()
        realm = TestRealmHelper.makeInMemoryRealm()
        sut = QuoteRepository(realm: realm)
    }

    override func tearDown() {
        sut = nil
        realm = nil
        super.tearDown()
    }

    // MARK: - Save

    func test_save_persistsQuote() {
        let quote = Quote()
        quote.text = "To be or not to be"

        sut.save(quote)

        XCTAssertEqual(realm.objects(Quote.self).count, 1)
        XCTAssertEqual(realm.objects(Quote.self).first?.text, "To be or not to be")
    }

    func test_saveWithTags_createsAndLinksTags() {
        let quote = Quote()
        quote.text = "Tagged quote"

        sut.save(quote, tagNames: ["성장", "사랑"])

        XCTAssertEqual(realm.objects(Tag.self).count, 2)
        XCTAssertEqual(quote.tags.count, 2)
        let tagNames = quote.tags.map(\.name)
        XCTAssertTrue(tagNames.contains("성장"))
        XCTAssertTrue(tagNames.contains("사랑"))
    }

    func test_saveWithTags_reusesExistingTag() {
        // 기존 태그 생성
        let existingTag = Tag()
        existingTag.name = "성장"
        try! realm.write { realm.add(existingTag) }

        let quote = Quote()
        quote.text = "Reuse tag"
        sut.save(quote, tagNames: ["성장", "위로"])

        XCTAssertEqual(realm.objects(Tag.self).count, 2) // "성장" 재사용 + "위로" 신규
        XCTAssertEqual(quote.tags.count, 2)
    }

    // MARK: - Toggle Favorite

    func test_toggleFavorite_flipsBool() {
        let quote = Quote()
        quote.text = "Favorite test"
        try! realm.write { realm.add(quote) }
        XCTAssertFalse(quote.isFavorite)

        sut.toggleFavorite(quote)

        XCTAssertTrue(quote.isFavorite)

        sut.toggleFavorite(quote)

        XCTAssertFalse(quote.isFavorite)
    }

    // MARK: - Update

    func test_update_changesTextPageAndTags() {
        let quote = Quote()
        quote.text = "Original"
        quote.pageNumber = 1
        sut.save(quote, tagNames: ["자아"])

        sut.update(quote, text: "Updated", pageNumber: 42, tagNames: ["성장", "사랑"])

        XCTAssertEqual(quote.text, "Updated")
        XCTAssertEqual(quote.pageNumber, 42)
        XCTAssertEqual(quote.tags.count, 2)
        XCTAssertFalse(quote.tags.map(\.name).contains("자아"))
    }

    // MARK: - Delete

    func test_delete_removesQuote() {
        let quote = Quote()
        quote.text = "To delete"
        try! realm.write { realm.add(quote) }

        sut.delete(quote)

        XCTAssertEqual(realm.objects(Quote.self).count, 0)
    }

    // MARK: - Fetch by ID

    func test_fetch_returnsQuoteById() {
        let quote = Quote()
        quote.text = "Find me"
        try! realm.write { realm.add(quote) }

        let found = sut.fetch(id: quote.id)

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.text, "Find me")
    }
}
