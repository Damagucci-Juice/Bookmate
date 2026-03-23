import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CardCustomizationViewController: UIViewController {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let quoteRepository = QuoteRepository()

    private let quoteText: String
    private let book: Book
    private let page: String?
    private let tags: [String]
    private var selectedStyle: CardStyleType = .green

    // MARK: - Init

    init(quoteText: String, book: Book, page: String?, tags: [String]) {
        self.quoteText = quoteText
        self.book = book
        self.page = page
        self.tags = tags
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    private let cardPreviewView = CardPreviewView()

    private let styleSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "카드 스타일"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = AppColor.textPrimary
        return l
    }()

    private let styleRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()

    private let buttonRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private let shareButton = PrimaryButton(title: "공유하기", icon: .share)

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = AppColor.card
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = AppColor.border.cgColor

        var config = UIButton.Configuration.plain()
        config.title = "저장하기"
        config.baseForegroundColor = AppColor.textPrimary
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.buttonLabel.font
            return out
        }
        config.image = AppIcon.bookmark.image(pointSize: 18, weight: .semibold)
        config.imagePadding = 8
        config.imagePlacement = .leading
        btn.configuration = config
        btn.tintColor = AppColor.textPrimary

        btn.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        return btn
    }()

    private var styleCircles: [(CardStyleType, CardStyleCircleView)] = []

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavigation()
        setupLayout()
        setupStyleCircles()
        configureCardPreview()
        bindActions()
    }

    // MARK: - Navigation

    private func setupNavigation() {
        title = "카드 꾸미기"

        let backImage = AppIcon.chevronLeft.image(pointSize: 18, weight: .medium)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = AppColor.textPrimary

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    // MARK: - Layout

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Card preview
        contentView.addSubview(cardPreviewView)
        cardPreviewView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(327)
            $0.height.equalTo(420)
        }

        // Style section
        contentView.addSubview(styleSectionLabel)
        styleSectionLabel.snp.makeConstraints {
            $0.top.equalTo(cardPreviewView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        contentView.addSubview(styleRow)
        styleRow.snp.makeConstraints {
            $0.top.equalTo(styleSectionLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        // Button row
        buttonRow.addArrangedSubview(shareButton)
        buttonRow.addArrangedSubview(saveButton)
        contentView.addSubview(buttonRow)
        buttonRow.snp.makeConstraints {
            $0.top.equalTo(styleRow.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Style Circles

    private func setupStyleCircles() {
        let styles: [(CardStyleType, [UIColor])] = [
            (.green, [AppColor.CardStyle.greenBg, AppColor.CardStyle.greenGradientEnd]),
            (.coral, [AppColor.CardStyle.coralBg, AppColor.CardStyle.coralGradientEnd]),
            (.dark,  [AppColor.CardStyle.darkBg, AppColor.CardStyle.darkGradientEnd]),
            (.white, [AppColor.CardStyle.whiteBg, AppColor.CardStyle.whiteBg]),
            (.blue,  [AppColor.CardStyle.blueBg, AppColor.CardStyle.blueGradientEnd]),
        ]

        for (type, colors) in styles {
            let circle = CardStyleCircleView(colors: colors)

            if type == .white {
                circle.layer.borderWidth = 1
                circle.layer.borderColor = AppColor.border.cgColor
            }

            circle.isSelectedStyle = (type == selectedStyle)

            let tap = UITapGestureRecognizer()
            circle.addGestureRecognizer(tap)
            circle.isUserInteractionEnabled = true

            tap.rx.event
                .subscribe(onNext: { [weak self] _ in
                    self?.selectStyle(type)
                })
                .disposed(by: disposeBag)

            styleCircles.append((type, circle))
            styleRow.addArrangedSubview(circle)
        }
    }

    private func selectStyle(_ type: CardStyleType) {
        selectedStyle = type

        for (styleType, circle) in styleCircles {
            if styleType == .white && styleType != type {
                circle.isSelectedStyle = false
                circle.layer.borderWidth = 1
                circle.layer.borderColor = AppColor.border.cgColor
            } else {
                circle.isSelectedStyle = (styleType == type)
            }
        }

        cardPreviewView.configure(styleType: type)
    }

    // MARK: - Card Preview

    private func configureCardPreview() {
        cardPreviewView.quoteText = quoteText
        cardPreviewView.bookTitle = book.title
        cardPreviewView.bookAuthor = book.author
        cardPreviewView.configure(styleType: selectedStyle)
    }

    // MARK: - Actions

    private func bindActions() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.presentingViewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        shareButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.shareCard()
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveAndDismiss()
            })
            .disposed(by: disposeBag)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func saveQuote() {
        let quote = Quote()
        quote.text = quoteText
        quote.book = book
        quote.pageNumber = page.flatMap { Int($0) }

        let style = CardStyle()
        style.type = selectedStyle.rawValue
        quote.cardStyle = style

        quoteRepository.save(quote, tagNames: tags)
    }

    private func saveAndDismiss() {
        saveQuote()
        navigationController?.presentingViewController?.dismiss(animated: true)
    }

    private func shareCard() {
        saveQuote()
        let image = cardPreviewView.renderToImage()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.navigationController?.presentingViewController?.dismiss(animated: true)
        }

        present(activityVC, animated: true)
    }
}
