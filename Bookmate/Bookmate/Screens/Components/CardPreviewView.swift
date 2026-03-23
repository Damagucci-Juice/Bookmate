import UIKit
import SnapKit

final class CardPreviewView: UIView {

    // MARK: - Properties

    private var gradientLayer = CAGradientLayer()
    private var styleType: CardStyleType = .green

    var quoteText: String = "" {
        didSet { quoteLabel.text = quoteText }
    }

    var bookTitle: String = "" {
        didSet { updateAttribution() }
    }

    var bookAuthor: String = "" {
        didSet { updateAttribution() }
    }

    // MARK: - UI

    private let quoteMarkLabel: UILabel = {
        let l = UILabel()
        l.text = "\u{201C}"
        l.font = AppFont.quoteIcon.font
        l.textAlignment = .left
        return l
    }()

    private let quoteLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.quoteText.font
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.quoteTextLineHeight
        l.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        return l
    }()

    private let attributionLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.shareCardAuthor.font
        l.textAlignment = .left
        return l
    }()

    private let watermarkLabel: UILabel = {
        let l = UILabel()
        l.text = "Bookmate"
        l.font = AppFont.shareCardWatermark.font
        l.textAlignment = .right
        l.alpha = 0.6
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        layer.cornerRadius = 24
        clipsToBounds = true

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        let topSection = UIView()
        topSection.addSubview(quoteMarkLabel)
        topSection.addSubview(quoteLabel)

        quoteMarkLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        quoteLabel.snp.makeConstraints {
            $0.top.equalTo(quoteMarkLabel.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        let bottomRow = UIStackView(arrangedSubviews: [attributionLabel, watermarkLabel])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing

        let contentStack = UIStackView(arrangedSubviews: [topSection, bottomRow])
        contentStack.axis = .vertical
        contentStack.distribution = .equalSpacing

        addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 32, bottom: 40, right: 32))
        }

        configure(styleType: .green)
    }

    // MARK: - Configure

    func configure(styleType: CardStyleType) {
        self.styleType = styleType

        let (bgColors, textColor, needsBorder) = colorsForStyle(styleType)

        gradientLayer.colors = bgColors.map { $0.cgColor }

        quoteMarkLabel.textColor = textColor.withAlphaComponent(0.3)
        quoteLabel.textColor = textColor
        attributionLabel.textColor = textColor.withAlphaComponent(0.7)
        watermarkLabel.textColor = textColor.withAlphaComponent(0.4)

        layer.borderWidth = needsBorder ? 1 : 0
        layer.borderColor = needsBorder ? AppColor.border.cgColor : nil

        updateQuoteText()
    }

    private func colorsForStyle(_ type: CardStyleType) -> ([UIColor], UIColor, Bool) {
        switch type {
        case .green:
            return ([AppColor.CardStyle.greenBg, AppColor.CardStyle.greenGradientEnd],
                    AppColor.CardStyle.lightText, false)
        case .coral:
            return ([AppColor.CardStyle.coralBg, AppColor.CardStyle.coralGradientEnd],
                    AppColor.CardStyle.lightText, false)
        case .dark:
            return ([AppColor.CardStyle.darkBg, AppColor.CardStyle.darkGradientEnd],
                    AppColor.CardStyle.lightText, false)
        case .white:
            return ([AppColor.CardStyle.whiteBg, AppColor.CardStyle.whiteBg],
                    AppColor.CardStyle.darkText, true)
        case .blue:
            return ([AppColor.CardStyle.blueBg, AppColor.CardStyle.blueGradientEnd],
                    AppColor.CardStyle.lightText, false)
        case .photo:
            // Placeholder: dark style for now
            return ([AppColor.CardStyle.darkBg, AppColor.CardStyle.darkGradientEnd],
                    AppColor.CardStyle.lightText, false)
        }
    }

    // MARK: - Helpers

    private func updateAttribution() {
        if bookAuthor.isEmpty {
            attributionLabel.text = bookTitle
        } else {
            attributionLabel.text = "\(bookTitle) · \(bookAuthor)"
        }
    }

    private func updateQuoteText() {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.quoteTextLineHeight
        quoteLabel.attributedText = NSAttributedString(
            string: quoteText,
            attributes: [
                .font: AppFont.quoteText.font,
                .foregroundColor: quoteLabel.textColor ?? .white,
                .paragraphStyle: style
            ]
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Render to Image

    func renderToImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
