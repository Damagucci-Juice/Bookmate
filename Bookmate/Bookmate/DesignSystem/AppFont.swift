import UIKit

enum AppFont {

    // MARK: - System UI (Pretendard)
    case sectionTitle
    case screenTitle
    case body
    case caption
    case meta
    case buttonLabel
    case filterChipActive
    case filterChipInactive
    case tag
    case tabLabelActive
    case tabLabelInactive
    case decorIcon
    case recommendBody

    // MARK: - Home Quote Card
    case cardQuoteMark
    case cardQuoteBody

    // MARK: - Share Card (Nanum Myeongjo)
    case quoteIcon
    case quoteText

    // MARK: - Brand (Outfit)
    case logo
    case shareCardAuthor
    case shareCardWatermark

    // MARK: - Misc (Inter)
    case statusBarTime

    // MARK: - Computed Property

    var font: UIFont {
        switch self {
        // System UI → SF Pro
        case .sectionTitle:        return .systemFont(ofSize: 22, weight: .semibold)
        case .screenTitle:         return .systemFont(ofSize: 18, weight: .semibold)
        case .body:                return .systemFont(ofSize: 15, weight: .medium)
        case .caption:             return .systemFont(ofSize: 13, weight: .medium)
        case .meta:                return .systemFont(ofSize: 12, weight: .regular)
        case .buttonLabel:         return .systemFont(ofSize: 16, weight: .semibold)
        case .filterChipActive:    return .systemFont(ofSize: 13, weight: .semibold)
        case .filterChipInactive:  return .systemFont(ofSize: 13, weight: .medium)
        case .tag:                 return .systemFont(ofSize: 11, weight: .semibold)
        case .tabLabelActive:      return .systemFont(ofSize: 10, weight: .semibold)
        case .tabLabelInactive:    return .systemFont(ofSize: 10, weight: .medium)
        case .decorIcon:           return .systemFont(ofSize: 16, weight: .regular)
        case .recommendBody:       return .systemFont(ofSize: 14, weight: .regular)
        case .shareCardAuthor:     return .systemFont(ofSize: 12, weight: .medium)

        // Home Quote Card → SF Pro
        case .cardQuoteMark:       return .systemFont(ofSize: 48, weight: .bold)
        case .cardQuoteBody:       return .systemFont(ofSize: 18, weight: .medium)

        // Brand → SF Pro (Outfit 대체)
        case .logo:                return .systemFont(ofSize: 26, weight: .bold)
        case .shareCardWatermark:  return .systemFont(ofSize: 13, weight: .bold)

        // Status Bar → SF Pro (Inter 대체)
        case .statusBarTime:       return .systemFont(ofSize: 16, weight: .semibold)

        // Share Card → Nanum Myeongjo (serif 감성 유지, Georgia 폴백)
        case .quoteIcon:           return UIFont(name: "NanumMyeongjoExtraBold", size: 40) ?? UIFont(name: "Georgia-Bold", size: 40)!
        case .quoteText:           return UIFont(name: "NanumMyeongjo", size: 17)          ?? UIFont(name: "Georgia", size: 17)!
        }
    }

    // MARK: - Letter Spacing & Line Height Constants

    enum Spacing {
        static let screenTitleLetterSpacing: CGFloat = -0.2
        static let quoteTextLetterSpacing: CGFloat = -0.3
        static let logoLetterSpacing: CGFloat = -0.5
        static let shareCardWatermarkLetterSpacing: CGFloat = -0.3

        static let bodyLineHeight: CGFloat = 1.6
        static let quoteTextLineHeight: CGFloat = 1.6
        static let quoteIconLineHeight: CGFloat = 0.5
    }
}
