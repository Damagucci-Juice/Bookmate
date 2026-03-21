import UIKit
import SnapKit

final class QuoteListItemView: UIView {

    private let quoteLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.body.font
        l.textColor = AppColor.textPrimary
        l.numberOfLines = 0

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.bodyLineHeight
        l.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        return l
    }()

    private let bookLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.meta.font
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let tagChip = TagChipView(title: "")

    private let metaStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [quoteLabel, metaStack])
        stack.axis = .vertical
        stack.spacing = 10

        metaStack.addArrangedSubview(bookLabel)
        metaStack.addArrangedSubview(tagChip)

        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
        }
    }

    func configure(quote: String, bookInfo: String, tag: String?, tagColor: UIColor? = nil, tagBgColor: UIColor? = nil) {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.bodyLineHeight
        quoteLabel.attributedText = NSAttributedString(
            string: quote,
            attributes: [
                .font: AppFont.body.font,
                .foregroundColor: AppColor.textPrimary,
                .paragraphStyle: style
            ]
        )
        bookLabel.text = bookInfo

        if let tag = tag, !tag.isEmpty {
            tagChip.isHidden = false
            tagChip.configure(title: tag, textColor: tagColor ?? AppColor.accent, bgColor: tagBgColor ?? AppColor.accentLight)
        } else {
            tagChip.isHidden = true
        }
    }
}
