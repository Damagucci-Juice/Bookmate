import Foundation
import RealmSwift
import RxSwift
import Realm

final class QuoteRepository {

    private let realm: Realm

    init(realm: Realm = .configured()) {
        self.realm = realm
    }

    // MARK: - Read

    /// 전체 문장 (최신순)
    func fetchAll() -> Observable<[Quote]> {
        let results = realm.objects(Quote.self).sorted(byKeyPath: "createdAt", ascending: false)
        return observe(results)
    }

    /// 특정 책의 문장 (최신순)
    func fetch(bookId: ObjectId) -> Observable<[Quote]> {
        let results = realm.objects(Quote.self)
            .filter("book.id == %@", bookId)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return observe(results)
    }

    /// 태그 필터링 (선택한 태그를 모두 포함하는 문장, AND 조건)
    func fetch(tagNames: [String]) -> Observable<[Quote]> {
        var results = realm.objects(Quote.self)
        for name in tagNames {
            results = results.filter("ANY tags.name == %@", name)
        }
        return observe(results.sorted(byKeyPath: "createdAt", ascending: false))
    }

    /// 태그가 없는 문장
    func fetchUntagged() -> Observable<[Quote]> {
        let results = realm.objects(Quote.self)
            .filter("tags.@count == 0")
            .sorted(byKeyPath: "createdAt", ascending: false)
        return observe(results)
    }

    // MARK: - Private

    private func observe<T: Object>(_ results: Results<T>) -> Observable<[T]> {
        Observable.create { observer in
            let token = results.observe { changes in
                switch changes {
                case .initial(let col), .update(let col, _, _, _):
                    observer.onNext(Array(col))
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { token.invalidate() }
        }
    }

    func fetch(id: ObjectId) -> Quote? {
        realm.object(ofType: Quote.self, forPrimaryKey: id)
    }

    // MARK: - Write

    func save(_ quote: Quote) {
        try? realm.write { realm.add(quote) }
    }

    /// Save quote and resolve tag names (reusing existing Tag objects or creating new ones)
    func save(_ quote: Quote, tagNames: [String]) {
        try? realm.write {
            realm.add(quote)
            for name in tagNames {
                if let existing = realm.objects(Tag.self).filter("name == %@", name).first {
                    quote.tags.append(existing)
                } else {
                    let newTag = Tag()
                    newTag.name = name
                    realm.add(newTag)
                    quote.tags.append(newTag)
                }
            }
        }
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

    func updateCardStyle(_ type: CardStyleType, for quote: Quote, backgroundImageFilename: String? = nil) {
        try? realm.write {
            if quote.cardStyle == nil {
                quote.cardStyle = CardStyle()
            }
            quote.cardStyle?.type = type.rawValue
            quote.cardStyle?.backgroundImageFilename = backgroundImageFilename
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

    // MARK: - Update (All-in-one)

    func update(_ quote: Quote, text: String, pageNumber: Int?, tagNames: [String]) {
        try? realm.write {
            quote.text = text
            quote.pageNumber = pageNumber
            quote.tags.removeAll()
            for name in tagNames {
                if let existing = realm.objects(Tag.self).filter("name == %@", name).first {
                    quote.tags.append(existing)
                } else {
                    let newTag = Tag()
                    newTag.name = name
                    realm.add(newTag)
                    quote.tags.append(newTag)
                }
            }
        }
    }

    // MARK: - Delete

    func delete(_ quote: Quote) {
        try? realm.write { realm.delete(quote) }
    }
}
