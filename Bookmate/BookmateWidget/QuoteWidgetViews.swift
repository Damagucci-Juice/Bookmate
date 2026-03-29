import SwiftUI
import WidgetKit

// MARK: - Design Tokens

private enum WidgetColor {
    // Light
    static let card = Color(red: 1, green: 1, blue: 1)
    static let accent = Color(red: 0x3D/255, green: 0x8A/255, blue: 0x5A/255)
    static let textPrimary = Color(red: 0x1A/255, green: 0x19/255, blue: 0x18/255)
    static let textTertiary = Color(red: 0x9C/255, green: 0x9B/255, blue: 0x99/255)

    // Green gradient for dark mode
    static let greenTop = Color(red: 0x3D/255, green: 0x8A/255, blue: 0x5A/255)
    static let greenBottom = Color(red: 0x2A/255, green: 0x6B/255, blue: 0x42/255)
}

// MARK: - Entry View (Router)

struct QuoteWidgetEntryView: View {
    var entry: QuoteEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        Group {
            if let quote = entry.quote {
                switch family {
                case .systemSmall:
                    SmallWidgetView(quote: quote, isDark: isDark)
                case .systemMedium:
                    MediumWidgetView(quote: quote, isDark: isDark)
                case .systemLarge:
                    LargeWidgetView(quote: quote, isDark: isDark)
                default:
                    SmallWidgetView(quote: quote, isDark: isDark)
                }
            } else {
                EmptyWidgetView(isDark: isDark)
            }
        }
        .containerBackground(for: .widget) {
            if isDark {
                LinearGradient(
                    colors: [WidgetColor.greenTop, WidgetColor.greenBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                WidgetColor.card
            }
        }
    }
}

// MARK: - Small Widget (155x155)

private struct SmallWidgetView: View {
    let quote: WidgetQuote
    let isDark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Quote icon
            Text("\u{201C}")
                .font(.custom("Outfit", size: 28).weight(.bold))
                .foregroundColor(isDark ? .white.opacity(0.3) : WidgetColor.accent)

            Spacer()

            // Quote text
            Text(quote.text)
                .font(.system(size: 13, weight: .semibold))
                .tracking(-0.2)
                .lineSpacing(13 * 0.5) // lineHeight 1.5
                .foregroundColor(isDark ? .white : WidgetColor.textPrimary)
                .lineLimit(3...5)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Bottom row
            HStack {
                Text(quote.author.isEmpty ? quote.bookTitle : quote.author)
                    .font(.custom("Outfit", size: 10).weight(.medium))
                    .foregroundColor(isDark ? .white.opacity(0.5) : WidgetColor.textTertiary)
                    .lineLimit(1)

                Spacer()

                Text("Bookmate")
                    .font(.custom("Outfit", size: 10).weight(.semibold))
                    .foregroundColor(isDark ? .white.opacity(0.4) : WidgetColor.accent.opacity(0.5))
            }
        }
        .padding(16)
    }
}

// MARK: - Medium Widget (329x155)

private struct MediumWidgetView: View {
    let quote: WidgetQuote
    let isDark: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Top section: quote + book cover
            HStack(alignment: .top, spacing: 12) {
                // Quote section
                VStack(alignment: .leading, spacing: 6) {
                    Text("\u{201C}")
                        .font(.custom("Outfit", size: 32).weight(.bold))
                        .foregroundColor(isDark ? .white.opacity(0.3) : WidgetColor.accent)

                    Text(quote.text)
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(-0.2)
                        .lineSpacing(15 * 0.5)
                        .foregroundColor(isDark ? .white : WidgetColor.textPrimary)
                        .lineLimit(3...4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Book cover
                if let imageData = quote.coverImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            Spacer()

            // Bottom row
            HStack {
                Text(bookInfoText)
                    .font(.custom("Outfit", size: 10).weight(.medium))
                    .foregroundColor(isDark ? .white.opacity(0.5) : WidgetColor.textTertiary)
                    .lineLimit(1)

                Spacer()

                Text("Bookmate")
                    .font(.custom("Outfit", size: 10).weight(.semibold))
                    .foregroundColor(isDark ? .white.opacity(0.4) : WidgetColor.accent.opacity(0.5))
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }

    private var bookInfoText: String {
        if !quote.bookTitle.isEmpty && !quote.author.isEmpty {
            return "\(quote.bookTitle) \u{00B7} \(quote.author)"
        }
        return quote.bookTitle.isEmpty ? quote.author : quote.bookTitle
    }
}

// MARK: - Large Widget (329x345)

private struct LargeWidgetView: View {
    let quote: WidgetQuote
    let isDark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Quote icon
            Text("\u{201C}")
                .font(.custom("Outfit", size: 40).weight(.bold))
                .foregroundColor(isDark ? .white.opacity(0.3) : WidgetColor.accent)

            Spacer()

            // Quote text
            Text("\u{201C}\(quote.text)\u{201D}")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.3)
                .lineSpacing(20 * 0.5)
                .foregroundColor(isDark ? .white : WidgetColor.textPrimary)
                .lineLimit(3...8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Author
            Text(quote.author.isEmpty ? quote.bookTitle : quote.author)
                .font(.custom("Outfit", size: 11).weight(.medium))
                .foregroundColor(isDark ? .white.opacity(0.5) : WidgetColor.textTertiary)

            Spacer()

            // Bottom row with logo
            HStack {
                Spacer()
                Text("Bookmate")
                    .font(.custom("Outfit", size: 10).weight(.semibold))
                    .foregroundColor(isDark ? .white.opacity(0.4) : WidgetColor.accent.opacity(0.5))
            }
        }
        .padding(24)
    }
}

// MARK: - Empty State

private struct EmptyWidgetView: View {
    let isDark: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("\u{201C}")
                .font(.custom("Outfit", size: 28).weight(.bold))
                .foregroundColor(isDark ? .white.opacity(0.3) : WidgetColor.accent)

            Text("즐겨찾기한 문장이 없어요")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.6) : WidgetColor.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
    }
}
