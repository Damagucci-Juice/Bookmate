import Foundation
import RealmSwift
@testable import Bookmate

enum TestRealmHelper {
    static func makeInMemoryRealm() -> Realm {
        var config = Realm.Configuration()
        config.inMemoryIdentifier = UUID().uuidString
        config.objectTypes = [Book.self, SearchedBook.self, Quote.self, Tag.self, CardStyle.self]
        return try! Realm(configuration: config)
    }
}
