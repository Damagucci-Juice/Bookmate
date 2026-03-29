import Foundation
import RealmSwift
import Realm

// MARK: - SearchedBook (검색 이력 전용, 임시)

class SearchedBook: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var author: String = ""
    @Persisted var isbn: String = ""
    @Persisted var coverImageURL: String = ""
    @Persisted var searchedAt: Date = Date()
}

// MARK: - Book (영구, Quote가 있는 도서)

class Book: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var author: String = ""
    @Persisted var isbn: String = ""
    @Persisted var coverImageData: Data?
    @Persisted var coverImageURL: String = ""
    @Persisted var memo: String = ""
    @Persisted var createdAt: Date = Date()

    @Persisted(originProperty: "book") var quotes: LinkingObjects<Quote>
}

// MARK: - Quote

class Quote: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var text: String = ""
    @Persisted var memo: String?
    @Persisted var pageNumber: Int?
    @Persisted var createdAt: Date = Date()
    @Persisted var isFavorite: Bool = false
    @Persisted var cardStyle: CardStyle?
    @Persisted var book: Book?
    @Persisted var tags: List<Tag>
}

// MARK: - Tag

class Tag: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""

    @Persisted(originProperty: "tags") var quotes: LinkingObjects<Quote>
}

// MARK: - CardStyle (EmbeddedObject)

class CardStyle: EmbeddedObject {
    @Persisted var type: String = CardStyleType.green.rawValue
    @Persisted var backgroundImageFilename: String?
}

enum CardStyleType: String, CaseIterable {
    case green
    case coral
    case dark
    case white
    case blue
    case photo
}

// MARK: - Realm Configuration

extension Realm {
    static func configured() -> Realm {
        do {
            return try Realm(configuration: SharedRealmConfig.configuration)
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - Seed Data

func seedDefaultTagsIfNeeded(realm: Realm) {
    let defaultTagNames = ["자아", "성장", "사랑", "위로"]
    let existing = Set(realm.objects(Tag.self).map(\.name))
    let toInsert = defaultTagNames.filter { !existing.contains($0) }
    guard !toInsert.isEmpty else { return }

    try? realm.write {
        for name in toInsert {
            let tag = Tag()
            tag.name = name
            realm.add(tag)
        }
    }
}
