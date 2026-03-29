import Foundation
import RealmSwift
import Realm

enum SharedRealmConfig {
    static let appGroupID = "group.com.gucci.Bookmate"

    static var sharedContainerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("App Group '\(appGroupID)' 컨테이너를 찾을 수 없습니다. Entitlements 설정을 확인하세요.")
        }
        return url
    }

    static var configuration: Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = sharedContainerURL.appendingPathComponent("default.realm")
        config.schemaVersion = 6
        config.migrationBlock = { _, _ in }
        config.objectTypes = [Book.self, SearchedBook.self, Quote.self, Tag.self, CardStyle.self]
        return config
    }

    /// 기존 앱 샌드박스의 Realm 파일을 App Group 공유 컨테이너로 복사 (최초 1회)
    static func migrateToSharedContainerIfNeeded() {
        let sharedRealmURL = sharedContainerURL.appendingPathComponent("default.realm")

        guard !FileManager.default.fileExists(atPath: sharedRealmURL.path) else { return }

        guard let oldURL = Realm.Configuration.defaultConfiguration.fileURL,
              FileManager.default.fileExists(atPath: oldURL.path) else { return }

        do {
            try FileManager.default.copyItem(at: oldURL, to: sharedRealmURL)

            let auxiliaryExtensions = ["lock", "note", "management"]
            for ext in auxiliaryExtensions {
                let oldAux = oldURL.appendingPathExtension(ext)
                let newAux = sharedRealmURL.appendingPathExtension(ext)
                if FileManager.default.fileExists(atPath: oldAux.path) {
                    try? FileManager.default.copyItem(at: oldAux, to: newAux)
                }
            }
        } catch {
            print("Realm migration to shared container failed: \(error)")
        }
    }
}

// MARK: - Widget Data Sync (App → Widget via App Group UserDefaults)

struct WidgetQuoteData: Codable {
    let id: String
    let text: String
    let bookTitle: String
    let author: String
    let coverImageData: Data?
}

enum WidgetDataStore {
    private static let suiteName = SharedRealmConfig.appGroupID
    private static let favoritesKey = "widget_favorite_quotes"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    /// 메인 앱에서 호출: 즐겨찾기된 Quote 목록을 위젯용으로 동기화
    static func syncFavorites(from realm: Realm) {
        let favorites = realm.objects(Quote.self).filter("isFavorite == true")
        let data = favorites.map { quote in
            WidgetQuoteData(
                id: quote.id.stringValue,
                text: quote.text,
                bookTitle: quote.book?.title ?? "",
                author: quote.book?.author ?? "",
                coverImageData: quote.book?.coverImageData
            )
        }
        if let encoded = try? JSONEncoder().encode(Array(data)) {
            sharedDefaults?.set(encoded, forKey: favoritesKey)
        }
    }

    /// 위젯에서 호출: 저장된 즐겨찾기 중 랜덤 1개 반환
    static func randomFavorite() -> WidgetQuoteData? {
        guard let data = sharedDefaults?.data(forKey: favoritesKey),
              let quotes = try? JSONDecoder().decode([WidgetQuoteData].self, from: data),
              !quotes.isEmpty else { return nil }
        return quotes.randomElement()
    }
}
