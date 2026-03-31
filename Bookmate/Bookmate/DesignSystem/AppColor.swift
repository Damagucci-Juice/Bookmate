import UIKit

// MARK: - UIColor Hex Initializer

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let length = hexSanitized.count
        if length == 8 {
            // RRGGBBAA
            self.init(
                red: CGFloat((rgb >> 24) & 0xFF) / 255,
                green: CGFloat((rgb >> 16) & 0xFF) / 255,
                blue: CGFloat((rgb >> 8) & 0xFF) / 255,
                alpha: CGFloat(rgb & 0xFF) / 255
            )
        } else {
            // RRGGBB
            self.init(
                red: CGFloat((rgb >> 16) & 0xFF) / 255,
                green: CGFloat((rgb >> 8) & 0xFF) / 255,
                blue: CGFloat(rgb & 0xFF) / 255,
                alpha: 1.0
            )
        }
    }
}

// MARK: - AppColor

enum AppColor {

    // MARK: Light Theme

    static let bg            = UIColor(hex: "#F5F4F1")
    static let card          = UIColor(hex: "#FFFFFF")
    static let accent        = UIColor(hex: "#3D8A5A")
    static let accentLight   = UIColor(hex: "#C8F0D8")
    static let coral         = UIColor(hex: "#D89575")
    static let textPrimary   = UIColor(hex: "#1A1918")
    static let textSecondary = UIColor(hex: "#6D6C6A")
    static let textTertiary  = UIColor(hex: "#9C9B99")
    static let border        = UIColor(hex: "#E5E4E1")
    static let tabInactive   = UIColor(hex: "#A8A7A5")

    // MARK: Dark (Deep Focus) Theme

    static let dfBg            = UIColor(hex: "#121412")
    static let dfSurface       = UIColor(hex: "#1A1C1A")
    static let dfCard          = UIColor(hex: "#2D302D")
    static let dfBorder        = UIColor(hex: "#3E423E")
    static let dfHighlight     = UIColor(hex: "#7FB685")
    static let dfAccent        = UIColor(hex: "#3D8A5A")
    static let dfTextPrimary   = UIColor(hex: "#E9ECEF")
    static let dfTextSecondary = UIColor(hex: "#ADB5BD")
    static let dfTextOnAccent  = UIColor(hex: "#FAFAFA")

    // MARK: Tag Colors

    enum Tag {
        static let selfText       = UIColor(hex: "#3D8A5A")  // 자아
        static let selfBackground = UIColor(hex: "#C8F0D8")

        static let loveText       = UIColor(hex: "#D89575")  // 사랑
        static let loveBackground = UIColor(hex: "#FDE8D8")

        static let growthText       = UIColor(hex: "#7B68EE")  // 성장
        static let growthBackground = UIColor(hex: "#E8E7FF")

        static let lifeText       = UIColor(hex: "#CC8800")  // 인생
        static let lifeBackground = UIColor(hex: "#FFF3CD")

        static let defaultText       = UIColor(hex: "#6D6C6A")  // 기본
        static let defaultBackground = UIColor(hex: "#E8E7E5")
    }

    // MARK: Card Style Presets

    enum CardStyle {
        static let greenBg = UIColor(hex: "#3D8A5A")
        static let coralBg = UIColor(hex: "#D89575")
        static let darkBg  = UIColor(hex: "#1A1918")
        static let whiteBg = UIColor(hex: "#FFFFFF")
        static let blueBg  = UIColor(hex: "#5B7FA6")

        static let greenGradientEnd = UIColor(hex: "#2A6B42")
        static let coralGradientEnd = UIColor(hex: "#B87355")
        static let darkGradientEnd  = UIColor(hex: "#2D302D")
        static let blueGradientEnd  = UIColor(hex: "#3A5A80")

        static let lightText = UIColor.white
        static let darkText  = UIColor(hex: "#1A1918")
    }

    // MARK: Wheel Card Colors

    enum WheelCard {
        static let beige      = UIColor(hex: "#F0E6D8")
        static let mutedGreen = UIColor(hex: "#8A9B7A")
        static let warmBrown  = UIColor(hex: "#C8A882")
        static let tan        = UIColor(hex: "#D4C0A0")
        static let sage       = UIColor(hex: "#B5BFA1")
        static let dustyTeal  = UIColor(hex: "#9BA8A0")
        static let softGreen  = UIColor(hex: "#A3B5A0")

        static let palette: [UIColor] = [beige, mutedGreen, warmBrown, tan, sage, dustyTeal, softGreen]
    }

    // MARK: Shadows

    static let cardShadow = UIColor(hex: "#1A191808")  // rgba(26,25,24,0.03)
    static let fabShadow  = UIColor(hex: "#3D8A5A40")  // accent @ 25%
}
