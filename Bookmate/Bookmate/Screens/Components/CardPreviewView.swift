import UIKit
import SnapKit

final class CardPreviewView: UIView {

    // MARK: - Properties

    private var gradientLayer = CAGradientLayer()
    private var styleType: CardStyleType = .green
    private var backgroundImage: UIImage?

    var quoteText: String = "" {
        didSet { quoteLabel.text = quoteText }
    }

    var bookTitle: String = "" {
        didSet { updateAttribution() }
    }

    var bookAuthor: String = "" {
        didSet { updateAttribution() }
    }

    var pageNumber: String = "" {
        didSet { updatePageLabel() }
    }

    // MARK: - UI

    private let quoteMarkLabel: UILabel = {
        let l = UILabel()
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = AppFont.Spacing.quoteIconLineHeight
        l.attributedText = NSAttributedString(
            string: "\u{201C}",
            attributes: [
                .font: AppFont.quoteIcon.font,
                .paragraphStyle: style
            ]
        )
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

    private let pageLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.shareCardAuthor.font
        l.textAlignment = .left
        l.isHidden = true
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

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
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

        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, above: backgroundImageView.layer)

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

        let leftStack = UIStackView(
            arrangedSubviews: [attributionLabel, pageLabel]
        )
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let bottomRow = UIStackView(arrangedSubviews: [leftStack, watermarkLabel])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing
        bottomRow.alignment = .bottom

        addSubview(topSection)
        addSubview(bottomRow)

        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(420)
        }

        topSection.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalToSuperview().inset(40)
            $0.bottom.equalTo(bottomRow.snp.top).offset(-20)
        }

        bottomRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(40)
        }

        configure(styleType: .green)
    }

    // MARK: - Configure

    func configure(styleType: CardStyleType, backgroundImage: UIImage? = nil) {
        self.styleType = styleType
        if let img = backgroundImage { self.backgroundImage = img }

        let isPhoto = styleType == .photo
        backgroundImageView.isHidden = !isPhoto
        backgroundImageView.image = isPhoto ? self.backgroundImage : nil

        let (bgColors, textColor, needsBorder) = colorsForStyle(styleType)
        gradientLayer.colors = bgColors.map { $0.cgColor }
        if isPhoto {
            gradientLayer.locations = [0.0, 0.4, 1.0]
        } else {
            gradientLayer.locations = nil
        }

        let quoteMarkStyle = NSMutableParagraphStyle()
        quoteMarkStyle.lineHeightMultiple = AppFont.Spacing.quoteIconLineHeight
        quoteMarkLabel.attributedText = NSAttributedString(
            string: "\u{201C}",
            attributes: [
                .font: AppFont.quoteIcon.font,
                .foregroundColor: textColor.withAlphaComponent(0.3),
                .paragraphStyle: quoteMarkStyle
            ]
        )
        quoteLabel.textColor = textColor
        attributionLabel.textColor = textColor.withAlphaComponent(0.7)
        pageLabel.textColor = textColor.withAlphaComponent(0.7)
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
            return ([UIColor.black.withAlphaComponent(0.87),
                     UIColor.black.withAlphaComponent(0.44),
                     UIColor.black.withAlphaComponent(0.93)],
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

    private func updatePageLabel() {
        if pageNumber.isEmpty {
            pageLabel.isHidden = true
        } else {
            pageLabel.text = "p.\(pageNumber)"
            pageLabel.isHidden = false
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
