import Foundation
import RealmSwift
import RxSwift
import RxCocoa

final class BookRepository {

    private let realm: Realm

    init(realm: Realm = .configured()) {
        self.realm = realm
    }

    // MARK: - Read

    func fetchAll() -> Observable<[Book]> {
        let results = realm.objects(Book.self).sorted(byKeyPath: "createdAt", ascending: false)
        return observe(results)
    }

    /// 문장이 하나 이상 있는 도서 (최신순)
    func fetchWithQuotes() -> Observable<[Book]> {
        let results = realm.objects(Book.self)
            .filter("quotes.@count > 0")
            .sorted(byKeyPath: "createdAt", ascending: false)
        return observe(results)
    }

    func fetch(id: ObjectId) -> Book? {
        realm.object(ofType: Book.self, forPrimaryKey: id)
    }

    func search(keyword: String) -> Observable<[Book]> {
        let results = realm.objects(Book.self)
            .filter("title CONTAINS[c] %@ OR author CONTAINS[c] %@", keyword, keyword)
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
            return Disposables.create()
        }
    }

    // MARK: - Write

    /// Naver API BookItem으로 Book을 생성하거나 ISBN이 같은 기존 Book을 반환
    @discardableResult
    func findOrCreate(from item: BookItem) -> Book {
        if let existing = realm.objects(Book.self)
            .filter("isbn == %@", item.isbn)
            .first {
            return existing
        }

        let book = Book()
        book.title = item.cleanTitle
        book.author = item.authors.joined(separator: ", ")
        book.isbn = item.isbn

        try? realm.write { realm.add(book) }
        return book
    }

    func save(_ book: Book) {
        try? realm.write { realm.add(book, update: .modified) }
    }

    func updateCoverImage(_ data: Data, for book: Book) {
        try? realm.write { book.coverImageData = data }
    }

    func delete(_ book: Book) {
        try? realm.write {
            // 연결된 Quote의 book 참조만 해제 (Quote 자체는 유지)
            book.quotes.forEach { $0.book = nil }
            realm.delete(book)
        }
    }
}
