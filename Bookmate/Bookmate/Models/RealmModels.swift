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
//        let config = Realm.Configuration(
//            schemaVersion: 5,
//            migrationBlock: { migration, oldSchemaVersion in
//                if oldSchemaVersion < 2 {
//                    migration.enumerateObjects(ofType: Book.className()) { oldObject, newObject in
//                        newObject?["lastSearchedAt"] = oldObject?["createdAt"] as? Date ?? Date()
//                    }
//                }
//                // v3: lastSearchedAt changed from Date to Date? — Realm handles automatically
//                if oldSchemaVersion < 4 {
//                    // v4: Book.lastSearchedAt 제거, SearchedBook 테이블 신설
//                    // lastSearchedAt != nil인 기존 Book → SearchedBook으로 복사
//                    migration.enumerateObjects(ofType: Book.className()) { oldObject, _ in
//                        guard let oldObject,
//                              let searchedAt = oldObject["lastSearchedAt"] as? Date else { return }
//                        let searched = migration.create(SearchedBook.className())
//                        searched["title"] = oldObject["title"] as? String ?? ""
//                        searched["author"] = oldObject["author"] as? String ?? ""
//                        searched["isbn"] = oldObject["isbn"] as? String ?? ""
//                        searched["coverImageURL"] = ""
//                        searched["searchedAt"] = searchedAt
//                    }
//                }
//                // v5: Book에 coverImageURL, memo 추가 — Realm이 자동 처리
//            },
//            objectTypes: [Book.self, SearchedBook.self, Quote.self, Tag.self, CardStyle.self]
//        )
//        return try! Realm(configuration: config)
        return try! Realm(configuration: .defaultConfiguration)
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
