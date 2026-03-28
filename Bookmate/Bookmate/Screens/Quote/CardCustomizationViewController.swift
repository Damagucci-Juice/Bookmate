import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa
import Realm

final class CardCustomizationViewController: UIViewController {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let quoteRepository = QuoteRepository()
    private let bookRepository = BookRepository()

    private let quoteText: String
    private let book: Book
    private let page: String?
    private let tags: [String]
    private let isExistingQuote: Bool
    private let initialCardStyle: CardStyle?
    private var selectedStyle: CardStyleType = .green
    private var backgroundImage: UIImage?

    // MARK: - Init

    init(quoteText: String, book: Book, page: String?, tags: [String], isExistingQuote: Bool = false, cardStyle: CardStyle? = nil) {
        self.quoteText = quoteText
        self.book = book
        self.page = page
        self.tags = tags
        self.isExistingQuote = isExistingQuote
        self.initialCardStyle = cardStyle
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
    private var photoCircle: CardStyleCircleView?

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
        restoreCardStyle()
        setupStyleCircles()
        if selectedStyle == .photo, let image = backgroundImage {
            updatePhotoCircleThumbnail(image)
        }
        configureCardPreview()
        bindActions()

        if isExistingQuote {
            saveButton.isHidden = true
        }
    }

    // MARK: - Navigation

    private func setupNavigation() {
        title = "카드 꾸미기"

        if navigationController?.viewControllers.first == self {
            // Modal root (인용구 리스트에서 진입): X만 표시
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        } else {
            // Pushed (캡처 flow에서 진입): back만 표시
            let backImage = AppIcon.chevronLeft.image(pointSize: 18, weight: .medium)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: backImage,
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )
            navigationItem.leftBarButtonItem?.tintColor = AppColor.textPrimary
        }
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

        // Photo style circle
        let photoColors = [AppColor.CardStyle.darkBg, AppColor.CardStyle.darkGradientEnd]
        let circle = CardStyleCircleView(colors: photoColors)
        photoCircle = circle

        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconView.image = UIImage(systemName: "photo", withConfiguration: config)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        circle.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
        }

        circle.isSelectedStyle = (selectedStyle == .photo)

        let tap = UITapGestureRecognizer()
        circle.addGestureRecognizer(tap)
        circle.isUserInteractionEnabled = true

        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.photoCircleTapped()
            })
            .disposed(by: disposeBag)

        styleCircles.append((.photo, circle))
        styleRow.addArrangedSubview(circle)
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

        if type == .photo {
            cardPreviewView.configure(styleType: type, backgroundImage: backgroundImage)
        } else {
            cardPreviewView.configure(styleType: type)
        }
    }

    private func photoCircleTapped() {
        if backgroundImage != nil {
            selectStyle(.photo)
        } else {
            presentPhotoPicker()
        }
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Style Restore

    private func restoreCardStyle() {
        guard let cardStyle = initialCardStyle,
              let type = CardStyleType(rawValue: cardStyle.type) else { return }
        selectedStyle = type
        if type == .photo, let filename = cardStyle.backgroundImageFilename {
            backgroundImage = CardBackgroundStorage.load(filename: filename)
        }
    }

    // MARK: - Card Preview

    private func configureCardPreview() {
        cardPreviewView.quoteText = quoteText
        cardPreviewView.bookTitle = book.title
        cardPreviewView.bookAuthor = book.author
        cardPreviewView.pageNumber = page ?? ""
        cardPreviewView.configure(styleType: selectedStyle, backgroundImage: backgroundImage)
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

        if selectedStyle == .photo, let image = backgroundImage {
            let filename = "\(quote.id.stringValue).jpg"
            if CardBackgroundStorage.save(image, filename: filename) {
                style.backgroundImageFilename = filename
            }
        }

        quote.cardStyle = style

        quoteRepository.save(quote, tagNames: tags)
        bookRepository.markAsRecentlyUsed(book)
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

// MARK: - PHPickerViewControllerDelegate

extension CardCustomizationViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.backgroundImage = image
                self?.updatePhotoCircleThumbnail(image)
                self?.selectStyle(.photo)
            }
        }
    }

    private func updatePhotoCircleThumbnail(_ image: UIImage) {
        guard let circle = photoCircle else { return }
        // Remove the icon and show thumbnail instead
        circle.subviews.forEach { $0.removeFromSuperview() }
        let thumbView = UIImageView(image: image)
        thumbView.contentMode = .scaleAspectFill
        thumbView.clipsToBounds = true
        circle.addSubview(thumbView)
        thumbView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
