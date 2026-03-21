import Foundation
import RealmSwift
import Realm
import RxSwift
import RxCocoa

final class BookRepository {

    private let realm: Realm

    init(realm: Realm = .configured()) {
        self.realm = realm
    }

    // MARK: - Read (Book)

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

    // MARK: - Read (SearchedBook)

    /// 최근 검색한 책 (searchedAt 내림차순)
    func fetchRecentlySearched() -> Observable<[SearchedBook]> {
        let results = realm.objects(SearchedBook.self)
            .sorted(byKeyPath: "searchedAt", ascending: false)
        return observe(results)
    }

    /// 최근 검색 기록 전체 삭제
    func clearRecentSearches() {
        let searched = realm.objects(SearchedBook.self)
        try? realm.write {
            realm.delete(searched)
        }
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

    // MARK: - Write (Book)

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
        book.coverImageURL = item.image

        try? realm.write { realm.add(book) }
        return book
    }

    func save(_ book: Book) {
        try? realm.write { realm.add(book, update: .modified) }
    }

    func updateCoverImage(_ data: Data, for book: Book) {
        try? realm.write { book.coverImageData = data }
    }

    func updateMemo(_ memo: String, for book: Book) {
        try? realm.write { book.memo = memo }
    }

    func delete(_ book: Book) {
        try? realm.write {
            // 연결된 Quote의 book 참조만 해제 (Quote 자체는 유지)
            book.quotes.forEach { $0.book = nil }
            realm.delete(book)
        }
    }

    // MARK: - Write (SearchedBook)

    /// 검색 이력에 추가하거나 기존 이력의 searchedAt 갱신
    @discardableResult
    func addToSearchHistory(from item: BookItem) -> SearchedBook {
        if let existing = realm.objects(SearchedBook.self)
            .filter("isbn == %@", item.isbn)
            .first {
            try? realm.write { existing.searchedAt = Date() }
            return existing
        }

        let searched = SearchedBook()
        searched.title = item.cleanTitle
        searched.author = item.authors.joined(separator: ", ")
        searched.isbn = item.isbn
        searched.coverImageURL = item.image

        try? realm.write { realm.add(searched) }
        return searched
    }

    /// 기존 SearchedBook의 searchedAt 갱신
    func markAsRecentlySearched(_ searched: SearchedBook) {
        try? realm.write { searched.searchedAt = Date() }
    }
}
