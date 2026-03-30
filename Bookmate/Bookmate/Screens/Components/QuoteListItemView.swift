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

    private let tagStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()

    let moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = AppColor.textTertiary
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let textStack = UIStackView(arrangedSubviews: [quoteLabel, bookLabel, tagStack])
        textStack.axis = .vertical
        textStack.spacing = 10
        textStack.alignment = .leading

        addSubview(textStack)
        addSubview(moreButton)

        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(bookLabel)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(CGSize(width: 32, height: 32))
        }

        textStack.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
            $0.trailing.equalTo(moreButton.snp.leading).offset(-8)
        }
    }

    func configure(quote: String, bookInfo: String, tags: [(name: String, textColor: UIColor, bgColor: UIColor)], highlightText: String? = nil) {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.bodyLineHeight

        let attributed = NSMutableAttributedString(
            string: quote,
            attributes: [
                .font: AppFont.body.font,
                .foregroundColor: AppColor.textPrimary,
                .paragraphStyle: style
            ]
        )

        if let keyword = highlightText, !keyword.isEmpty {
            var searchRange = quote.startIndex..<quote.endIndex
            while let range = quote.range(of: keyword, options: .caseInsensitive, range: searchRange) {
                let nsRange = NSRange(range, in: quote)
                attributed.addAttribute(.backgroundColor, value: AppColor.accentLight, range: nsRange)
                attributed.addAttribute(.foregroundColor, value: AppColor.accent, range: nsRange)
                searchRange = range.upperBound..<quote.endIndex
            }
        }

        quoteLabel.attributedText = attributed
        bookLabel.text = bookInfo

        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for tag in tags.prefix(3) {
            let capsule = CapsuleTagLabel()
            capsule.text = tag.name
            capsule.textColor = tag.textColor
            capsule.backgroundColor = tag.bgColor
            tagStack.addArrangedSubview(capsule)
        }

        tagStack.isHidden = tags.isEmpty
    }

}

// MARK: - Capsule Tag Label

private final class CapsuleTagLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = AppFont.meta.font
        textAlignment = .center
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    private let insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
