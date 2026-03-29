import Foundation

struct WidgetQuote {
    let id: String
    let text: String
    let bookTitle: String
    let author: String
    let coverImageData: Data?
}

enum WidgetQuoteLoader {

    private static let suiteName = "group.com.gucci.Bookmate"
    private static let favoritesKey = "widget_favorite_quotes"

    static func randomFavorite() -> WidgetQuote? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: favoritesKey) else { return nil }

        struct QuoteData: Codable {
            let id: String
            let text: String
            let bookTitle: String
            let author: String
            let coverImageData: Data?
        }

        guard let quotes = try? JSONDecoder().decode([QuoteData].self, from: data),
              let picked = quotes.randomElement() else { return nil }

        return WidgetQuote(
            id: picked.id,
            text: picked.text,
            bookTitle: picked.bookTitle,
            author: picked.author,
            coverImageData: picked.coverImageData
        )
    }
}
