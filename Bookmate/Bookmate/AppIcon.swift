import UIKit

enum AppIcon: String, CaseIterable {
    case bell
    case search
    case scan
    case chevronLeft
    case close
    case zap
    case signal
    case wifi
    case batteryFull
    case ellipsis
    case house
    case circlePlus
    case user
    case bookOpen
    case save
    case link
    case messageCircle
    case moreHorizontal
    case chevronRight
    case download
    case share
    case bookmark

    var defaultSize: CGFloat {
        switch self {
        case .bell, .search, .scan, .ellipsis, .link, .messageCircle, .moreHorizontal, .download, .share, .bookmark:
            return 24
        case .chevronLeft, .chevronRight, .close, .zap:
            return 22
        case .save:
            return 20
        case .house, .circlePlus, .user, .bookOpen:
            return 18
        case .signal, .wifi, .batteryFull:
            return 16
        }
    }

    /// SF Symbol name closest to the Lucide icon
    var sfSymbolName: String {
        switch self {
        case .bell:            return "bell"
        case .search:          return "magnifyingglass"
        case .scan:            return "viewfinder"
        case .chevronLeft:     return "chevron.left"
        case .chevronRight:    return "chevron.right"
        case .close:           return "xmark"
        case .zap:             return "bolt.fill"
        case .signal:          return "cellularbars"
        case .wifi:            return "wifi"
        case .batteryFull:     return "battery.100"
        case .ellipsis:        return "ellipsis"
        case .house:           return "house"
        case .circlePlus:      return "plus.circle"
        case .user:            return "person"
        case .bookOpen:        return "book"
        case .save:            return "square.and.arrow.down"
        case .link:            return "link"
        case .messageCircle:   return "message"
        case .moreHorizontal:  return "ellipsis"
        case .download:        return "arrow.down.circle"
        case .share:           return "square.and.arrow.up"
        case .bookmark:        return "bookmark"
        }
    }

    func image(pointSize: CGFloat? = nil, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        let size = pointSize ?? defaultSize
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        return UIImage(systemName: sfSymbolName, withConfiguration: config)
    }
}
