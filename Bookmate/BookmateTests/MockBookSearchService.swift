import RxSwift
@testable import Bookmate

final class MockBookSearchService: BookSearchServiceProtocol {

    var stubbedResult: Result<BookSearchResponse, Error> = .success(
        BookSearchResponse(
            lastBuildDate: "Mon, 01 Jan 2024 00:00:00 +0900",
            total: 0,
            start: 1,
            display: 20,
            items: []
        )
    )

    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?

    func search(query: String, display: Int, start: Int) -> Observable<BookSearchResponse> {
        searchCallCount += 1
        lastQuery = query
        switch stubbedResult {
        case .success(let response):
            return .just(response)
        case .failure(let error):
            return .error(error)
        }
    }
}
