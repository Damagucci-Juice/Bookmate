import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift

final class BookDetailViewController: UIViewController {

    // MARK: - Dependencies

    private let disposeBag = DisposeBag()
    private let quoteRepository = QuoteRepository()
    private let book: Book
    private var quotes: [Quote] = []
    private var selectedTags: [Tag] = []
    private let realm = Realm.configured()

    // MARK: - Init

    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .onDrag
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        return sv
    }()

    // Book Info
    private let bookInfoRow = BookInfoRowView()

    // Memo Section
    private let memoSectionLabel = SectionLabelView(text: "나의 메모")
    private let memoInputView = MemoInputView()

    // Quote Section
    private let quoteSectionLabelRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()

    private let quoteSectionLabel = SectionLabelView(text: "수집한 문장")

    private let quoteMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("더보기", for: .normal)
        btn.titleLabel?.font = AppFont.caption.font
        btn.setTitleColor(AppColor.accent, for: .normal)
        return btn
    }()

    private let quoteCard: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let quoteCardStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()

    private let emptyQuoteLabel: UILabel = {
        let l = UILabel()
        l.text = "아직 수집한 문장이 없습니다"
        l.font = AppFont.recommendBody.font
        l.textColor = AppColor.textTertiary
        l.textAlignment = .center
        return l
    }()

    private let ctaContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var cameraScanButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = AppIcon.scan.image(pointSize: 18, weight: .medium)
        config.title = "카메라 스캔"
        config.baseForegroundColor = AppColor.accent
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.caption.font
            return out
        }
        btn.configuration = config
        btn.backgroundColor = AppColor.accent.withAlphaComponent(0.06)
        btn.layer.cornerRadius = 10
        return btn
    }()

    private lazy var manualEntryButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        let pencilConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        config.image = UIImage(systemName: "pencil.line", withConfiguration: pencilConfig)
        config.title = "직접 등록"
        config.baseForegroundColor = AppColor.accent
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.caption.font
            return out
        }
        btn.configuration = config
        btn.backgroundColor = AppColor.accent.withAlphaComponent(0.06)
        btn.layer.cornerRadius = 10
        return btn
    }()

    // Tag Section
    private let tagSectionLabelRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()

    private let tagSectionLabel = SectionLabelView(text: "태그")

    private let tagHintLabel: UILabel = {
        let l = UILabel()
        l.text = "최대 3개"
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let tagFlowContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()

    // Save Button
    private let saveButton = SaveButton(title: "문장 저장하기")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavBar()
        setupLayout()
        configureBookInfo()
        bindActions()
        loadQuotes()
        loadTags()
    }

    // MARK: - Navigation Bar

    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.bg
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        let backImage = AppIcon.chevronLeft.image(pointSize: 22, weight: .medium)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = AppColor.textPrimary
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 24, right: 20))
            $0.width.equalTo(scrollView).offset(-40)
        }

        // Book Info
        contentStack.addArrangedSubview(bookInfoRow)

        // Divider
        contentStack.addArrangedSubview(DividerView())

        // Memo Section
        let memoSection = UIStackView(arrangedSubviews: [memoSectionLabel, memoInputView])
        memoSection.axis = .vertical
        memoSection.spacing = 10
        contentStack.addArrangedSubview(memoSection)

        // Quote Section
        quoteSectionLabelRow.addArrangedSubview(quoteSectionLabel)
        quoteSectionLabelRow.addArrangedSubview(quoteMoreButton)

        quoteCard.addSubview(quoteCardStack)
        quoteCardStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16))
        }

        ctaContainer.addArrangedSubview(cameraScanButton)
        ctaContainer.addArrangedSubview(manualEntryButton)
        cameraScanButton.snp.makeConstraints { $0.height.equalTo(44) }
        manualEntryButton.snp.makeConstraints { $0.height.equalTo(44) }

        let quoteSection = UIStackView(arrangedSubviews: [quoteSectionLabelRow, quoteCard, ctaContainer])
        quoteSection.axis = .vertical
        quoteSection.spacing = 10
        contentStack.addArrangedSubview(quoteSection)

        // Tag Section
        tagSectionLabelRow.addArrangedSubview(tagSectionLabel)
        tagSectionLabelRow.addArrangedSubview(tagHintLabel)

        let tagSection = UIStackView(arrangedSubviews: [tagSectionLabelRow, tagFlowContainer])
        tagSection.axis = .vertical
        tagSection.spacing = 6
        contentStack.addArrangedSubview(tagSection)

        // Save Button
        contentStack.addArrangedSubview(saveButton)
    }

    // MARK: - Configure

    private func configureBookInfo() {
        let coverURL: URL? = {
            if let data = book.coverImageData, let _ = UIImage(data: data) {
                return nil
            }
            return nil
        }()
        bookInfoRow.configure(
            title: book.title,
            author: book.author,
            page: nil,
            coverURL: coverURL
        )

        // Set cover from local data if available
        if let data = book.coverImageData, let image = UIImage(data: data) {
            setCoverImage(image)
        }
    }

    private func setCoverImage(_ image: UIImage) {
        // Access the coverImageView via the BookInfoRowView's subviews
        if let mainStack = bookInfoRow.subviews.first as? UIStackView,
           let imageView = mainStack.arrangedSubviews.first as? UIImageView {
            imageView.image = image
        }
    }

    // MARK: - Data

    private func loadQuotes() {
        quoteRepository.fetch(bookId: book.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] quotes in
                guard let self else { return }
                self.quotes = quotes
                self.updateQuoteCard()
                self.updatePageLabel()
            })
            .disposed(by: disposeBag)
    }

    private func updateQuoteCard() {
        quoteCardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if quotes.isEmpty {
            quoteCardStack.addArrangedSubview(emptyQuoteLabel)
            quoteMoreButton.isHidden = true
        } else {
            quoteMoreButton.isHidden = false
            for (index, quote) in quotes.prefix(3).enumerated() {
                let label = UILabel()
                label.text = quote.text
                label.font = .systemFont(ofSize: 15, weight: .regular)
                label.textColor = AppColor.textPrimary
                label.numberOfLines = 0

                let style = NSMutableParagraphStyle()
                style.lineHeightMultiple = 1.7
                label.attributedText = NSAttributedString(
                    string: quote.text,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                        .foregroundColor: AppColor.textPrimary,
                        .paragraphStyle: style
                    ]
                )

                quoteCardStack.addArrangedSubview(label)

                if index < min(quotes.count, 3) - 1 {
                    let divider = UIView()
                    divider.backgroundColor = AppColor.border
                    divider.snp.makeConstraints { $0.height.equalTo(1) }
                    quoteCardStack.addArrangedSubview(divider)
                }
            }
        }
    }

    private func updatePageLabel() {
        guard let latestQuote = quotes.first,
              let page = latestQuote.pageNumber else {
            bookInfoRow.configure(title: book.title, author: book.author, page: nil)
            return
        }
        bookInfoRow.configure(
            title: book.title,
            author: book.author,
            page: "p. \(page)"
        )
        // Re-apply cover image
        if let data = book.coverImageData, let image = UIImage(data: data) {
            setCoverImage(image)
        }
    }

    private func loadTags() {
        let allTags = Array(realm.objects(Tag.self).sorted(byKeyPath: "name"))
        updateTagChips(allTags: allTags)
    }

    private func updateTagChips(allTags: [Tag]) {
        tagFlowContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for tag in selectedTags {
            let chip = TagChipView(title: "# \(tag.name)")
            chip.configure(title: "# \(tag.name)", textColor: AppColor.accent, bgColor: AppColor.accentLight)
            tagFlowContainer.addArrangedSubview(chip)
        }

        // Unselected tags (up to fill 3 total)
        let unselected = allTags.filter { tag in !selectedTags.contains(where: { $0.id == tag.id }) }
        let remaining = 3 - selectedTags.count
        for tag in unselected.prefix(max(0, remaining)) {
            let chip = TagChipView(title: "# \(tag.name)")
            chip.configure(
                title: "# \(tag.name)",
                textColor: AppColor.textSecondary,
                bgColor: AppColor.bg
            )
            chip.layer.borderWidth = 1
            chip.layer.borderColor = AppColor.border.cgColor
            tagFlowContainer.addArrangedSubview(chip)
        }

        // Add button
        if selectedTags.count < 3 {
            let addChip = TagChipView(title: "+ 추가")
            addChip.configure(
                title: "+ 추가",
                textColor: AppColor.textTertiary,
                bgColor: AppColor.bg
            )
            addChip.layer.borderWidth = 1
            addChip.layer.borderColor = AppColor.border.cgColor
            tagFlowContainer.addArrangedSubview(addChip)
        }
    }

    // MARK: - Actions

    private func bindActions() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveMemo()
            })
            .disposed(by: disposeBag)
    }

    private func saveMemo() {
        let memoText = memoInputView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Save memo to the latest quote if exists
        if let latestQuote = quotes.first, !memoText.isEmpty {
            quoteRepository.updateMemo(memoText, for: latestQuote)
        }
        navigationController?.popViewController(animated: true)
    }
}
