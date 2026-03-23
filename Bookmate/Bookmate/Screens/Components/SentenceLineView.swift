import UIKit
import SnapKit

final class SentenceLineView: UIView {

    enum SelectionState {
        case unselected
        case selected
        case adjacent
    }

    var selectionState: SelectionState = .unselected {
        didSet { updateAppearance() }
    }

    private let sentenceLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 10

        addSubview(sentenceLabel)
        sentenceLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }

    private func updateAppearance() {
        let textColor: UIColor
        let bgColor: UIColor
        let weight: UIFont.Weight

        switch selectionState {
        case .selected:
            bgColor = AppColor.accent
            textColor = .white
            weight = .semibold
        case .adjacent:
            bgColor = AppColor.accent.withAlphaComponent(0.13)
            textColor = AppColor.textSecondary
            weight = .medium
        case .unselected:
            bgColor = .clear
            textColor = AppColor.textTertiary
            weight = .medium
        }

        backgroundColor = bgColor

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        sentenceLabel.attributedText = NSAttributedString(
            string: sentenceLabel.text ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: weight),
                .foregroundColor: textColor,
                .paragraphStyle: style,
                .kern: AppFont.Spacing.screenTitleLetterSpacing
            ]
        )
    }

    func configure(text: String, state: SelectionState) {
        sentenceLabel.text = text
        selectionState = state
    }
}
