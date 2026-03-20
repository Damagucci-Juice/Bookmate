import Foundation
import RealmSwift
import RxSwift

final class QuoteRepository {

    private let realm: Realm

    init(realm: Realm = .configured()) {
        self.realm = realm
    }

    // MARK: - Read

    /// 전체 문장 (최신순)
    func fetchAll() -> Observable<[Quote]> {
        let results = realm.objects(Quote.self).sorted(byKeyPath: "createdAt", ascending: false)
        return Observable.collection(from: results)
            .map(Array.init)
    }

    /// 특정 책의 문장 (최신순)
    func fetch(bookId: ObjectId) -> Observable<[Quote]> {
        let results = realm.objects(Quote.self)
            .filter("book.id == %@", bookId)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return Observable.collection(from: results)
            .map(Array.init)
    }

    /// 태그 필터링 (선택한 태그를 모두 포함하는 문장, AND 조건)
    func fetch(tagNames: [String]) -> Observable<[Quote]> {
        var results = realm.objects(Quote.self)
        for name in tagNames {
            results = results.filter("ANY tags.name == %@", name)
        }
        return Observable.collection(from: results.sorted(byKeyPath: "createdAt", ascending: false))
            .map(Array.init)
    }

    /// 태그가 없는 문장
    func fetchUntagged() -> Observable<[Quote]> {
        let results = realm.objects(Quote.self)
            .filter("tags.@count == 0")
            .sorted(byKeyPath: "createdAt", ascending: false)
        return Observable.collection(from: results)
            .map(Array.init)
    }

    func fetch(id: ObjectId) -> Quote? {
        realm.object(ofType: Quote.self, forPrimaryKey: id)
    }

    // MARK: - Write

    func save(_ quote: Quote) {
        try? realm.write { realm.add(quote) }
    }

    func updateText(_ text: String, for quote: Quote) {
        try? realm.write { quote.text = text }
    }

    func updateMemo(_ memo: String?, for quote: Quote) {
        try? realm.write { quote.memo = memo }
    }

    func updatePageNumber(_ page: Int?, for quote: Quote) {
        try? realm.write { quote.pageNumber = page }
    }

    func updateCardStyle(_ type: CardStyleType, for quote: Quote) {
        try? realm.write {
            if quote.cardStyle == nil {
                quote.cardStyle = CardStyle()
            }
            quote.cardStyle?.type = type.rawValue
        }
    }

    // MARK: - Tag Management

    func addTag(_ tag: Tag, to quote: Quote) {
        guard !quote.tags.contains(tag) else { return }
        try? realm.write { quote.tags.append(tag) }
    }

    func removeTag(_ tag: Tag, from quote: Quote) {
        guard let index = quote.tags.firstIndex(of: tag) else { return }
        try? realm.write { quote.tags.remove(at: index) }
    }

    func setTags(_ tags: [Tag], for quote: Quote) {
        try? realm.write {
            quote.tags.removeAll()
            quote.tags.append(objectsIn: tags)
        }
    }

    // MARK: - Delete

    func delete(_ quote: Quote) {
        try? realm.write { realm.delete(quote) }
    }
}
