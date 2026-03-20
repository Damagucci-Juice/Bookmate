import Foundation
import Alamofire
import RxSwift

final class NaverBookService {

    private let clientID: String
    private let clientSecret: String
    private let baseURL = "https://openapi.naver.com/v1/search/book.json"

    init() {
        guard let id = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_ID") as? String,
              let secret = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_SECRET") as? String else {
            fatalError("NAVER_CLIENT_ID / NAVER_CLIENT_SECRET not found in Info.plist")
        }
        self.clientID = id
        self.clientSecret = secret
    }

    func search(query: String, display: Int = 20, start: Int = 1) -> Observable<BookSearchResponse> {
        Observable.create { observer in
            let headers: HTTPHeaders = [
                "X-Naver-Client-Id": self.clientID,
                "X-Naver-Client-Secret": self.clientSecret
            ]
            let parameters: Parameters = [
                "query": query,
                "display": display,
                "start": start
            ]

            let request = AF.request(
                self.baseURL,
                parameters: parameters,
                headers: headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let searchResponse = try JSONDecoder().decode(BookSearchResponse.self, from: data)
                        observer.onNext(searchResponse)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create { request.cancel() }
        }
    }
}
