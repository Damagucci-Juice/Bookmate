import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift

final class BookDetailViewController: UIViewController {

    // MARK: - Dependencies

    private let disposeBag = DisposeBag()
    private let bookRepository = BookRepository()
    private let quoteRepository = QuoteRepository()
    private let book: Book
    private var quotes: [Quote] = []
    private var selectedTags: [Tag] = []

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
        btn.isHidden = true
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

        quoteCardStack.addArrangedSubview(emptyQuoteLabel)

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

    // MARK: - Configure Book Info (from Model)

    private func configureBookInfo() {
        // Cover: prefer local data, fall back to URL
        let coverURL: URL? = {
            guard !book.coverImageURL.isEmpty else { return nil }
            return URL(string: book.coverImageURL)
        }()

        bookInfoRow.configure(
            title: book.title,
            author: book.author,
            page: nil,
            coverURL: coverURL
        )

        if let data = book.coverImageData {
            bookInfoRow.configureCover(data: data)
        }

        // Memo: restore from Book model
        if !book.memo.isEmpty {
            memoInputView.text = book.memo
        }
    }

    // MARK: - Load Quotes (from QuoteRepository)

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
            quoteMoreButton.isHidden = quotes.count <= 3
            for (index, quote) in quotes.prefix(3).enumerated() {
                let label = UILabel()
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
            bookInfoRow.configurePage(nil)
            return
        }
        bookInfoRow.configurePage("p. \(page)")
    }

    // MARK: - Load Tags (from Realm)

    private func loadTags() {
        seedDefaultTagsIfNeeded(realm: Realm.configured())
        let allTags = Array(Realm.configured().objects(Tag.self).sorted(byKeyPath: "name"))
        updateTagChips(allTags: allTags)
    }

    private func updateTagChips(allTags: [Tag]) {
        tagFlowContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for tag in selectedTags {
            let chip = makeTagChip(tag: tag, selected: true)
            tagFlowContainer.addArrangedSubview(chip)
        }

        let unselected = allTags.filter { tag in !selectedTags.contains(where: { $0.id == tag.id }) }
        let remaining = 3 - selectedTags.count
        for tag in unselected.prefix(max(0, remaining)) {
            let chip = makeTagChip(tag: tag, selected: false)
            tagFlowContainer.addArrangedSubview(chip)
        }

        // + 추가 button
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

        // Trailing spacer to prevent chips from stretching
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tagFlowContainer.addArrangedSubview(spacer)
    }

    private func makeTagChip(tag: Tag, selected: Bool) -> TagChipView {
        let chip = TagChipView(title: "# \(tag.name)")
        if selected {
            chip.configure(title: "# \(tag.name)", textColor: AppColor.accent, bgColor: AppColor.accentLight)
        } else {
            chip.configure(title: "# \(tag.name)", textColor: AppColor.textSecondary, bgColor: AppColor.bg)
            chip.layer.borderWidth = 1
            chip.layer.borderColor = AppColor.border.cgColor
        }

        let tapGesture = UITapGestureRecognizer()
        chip.addGestureRecognizer(tapGesture)
        chip.isUserInteractionEnabled = true

        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.toggleTag(tag)
            })
            .disposed(by: disposeBag)

        return chip
    }

    private func toggleTag(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            guard selectedTags.count < 3 else { return }
            selectedTags.append(tag)
        }
        let allTags = Array(Realm.configured().objects(Tag.self).sorted(byKeyPath: "name"))
        updateTagChips(allTags: allTags)
    }

    // MARK: - Actions

    private func bindActions() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.save()
            })
            .disposed(by: disposeBag)

        manualEntryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let vc = ManualQuoteEntryViewController(book: self.book)
                vc.modalPresentationStyle = .pageSheet
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func save() {
        // Save memo to Book
        let memoText = memoInputView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        bookRepository.updateMemo(memoText, for: book)

        // Apply selected tags to all quotes of this book
        for quote in quotes {
            quoteRepository.setTags(selectedTags, for: quote)
        }

        navigationController?.popViewController(animated: true)
    }
}
