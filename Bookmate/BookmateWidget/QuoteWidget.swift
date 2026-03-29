import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: WidgetQuote?
}

struct QuoteProvider: TimelineProvider {

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, quote: WidgetQuote(
            id: "",
            text: "삶이 있는 한 희망은 있다.",
            bookTitle: "명상록",
            author: "키케로",
            coverImageData: nil
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let quote = WidgetQuoteLoader.randomFavorite()
        completion(QuoteEntry(date: .now, quote: quote))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let quote = WidgetQuoteLoader.randomFavorite()
        let entry = QuoteEntry(date: .now, quote: quote)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct QuoteWidget: Widget {
    let kind = "com.gucci.Bookmate.QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "bookmate://quote/\(entry.quote?.id ?? "")"))
        }
        .configurationDisplayName("오늘의 문장")
        .description("즐겨찾기한 문장을 위젯으로 만나보세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
