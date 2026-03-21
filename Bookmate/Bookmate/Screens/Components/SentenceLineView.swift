import UIKit
import SnapKit

final class SentenceLineView: UIView {

    var isSelectedState: Bool = false {
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
        backgroundColor = isSelectedState ? AppColor.accent : .clear

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        sentenceLabel.attributedText = NSAttributedString(
            string: sentenceLabel.text ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: isSelectedState ? .semibold : .medium),
                .foregroundColor: isSelectedState ? UIColor.white : AppColor.textTertiary,
                .paragraphStyle: style,
                .kern: AppFont.Spacing.screenTitleLetterSpacing
            ]
        )
    }

    func configure(text: String, selected: Bool) {
        sentenceLabel.text = text
        isSelectedState = selected
    }
}
