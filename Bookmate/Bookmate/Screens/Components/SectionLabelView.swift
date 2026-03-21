import UIKit

final class SectionLabelView: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = AppFont.caption.font
        textColor = AppColor.textSecondary
    }

    required init?(coder: NSCoder) { fatalError() }
}
