import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RealmSwift

final class ManualQuoteEntryViewController: UIViewController {

    // MARK: - Dependencies

    private let book: Book
    private let existingQuote: Quote?
    private let quoteRepository = QuoteRepository()
    private let bookRepository = BookRepository()
    private let disposeBag = DisposeBag()
    private let maxCharacterCount = Quote.maxCharacterCount

    // MARK: - Init

    init(book: Book, quote: Quote? = nil) {
        self.book = book
        self.existingQuote = quote
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
        sv.spacing = 20
        return sv
    }()

    // Quote Text
    private let quoteSectionLabel = SectionLabelView(text: "문장")

    private let quoteContainer: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let quotePlaceholder: UILabel = {
        let l = UILabel()
        l.text = "문장을 입력해주세요..."
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let quoteTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = AppColor.textPrimary
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    private let charCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = AppColor.textTertiary
        l.textAlignment = .right
        return l
    }()

    // Page Number
    private let pageSectionLabel = SectionLabelView(text: "페이지 번호")

    private let pageTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.textColor = AppColor.textPrimary
        tf.keyboardType = .numberPad
        tf.backgroundColor = AppColor.card
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppColor.border.cgColor
        tf.attributedPlaceholder = NSAttributedString(
            string: "선택 사항",
            attributes: [.foregroundColor: AppColor.textTertiary]
        )
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    // Tag Section
    private let tagSectionLabel = SectionLabelView(text: "태그")

    private let tagInputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let hashLabel: UILabel = {
        let l = UILabel()
        l.text = "#"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = AppColor.accent
        return l
    }()

    private let tagTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "태그 입력"
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = AppColor.textPrimary
        tf.returnKeyType = .done
        return tf
    }()

    private let tagHintLabel: UILabel = {
        let l = UILabel()
        l.text = "최대 3개까지 지정할 수 있어요"
        l.font = .systemFont(ofSize: 11)
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let suggestLabel: UILabel = {
        let l = UILabel()
        l.text = "추천 태그"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = AppColor.textSecondary
        return l
    }()

    private lazy var suggestCollectionView: UICollectionView = {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1.0 / 4.0),
            heightDimension: .absolute(36)
        ))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(36)),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        let layout = UICollectionViewCompositionalLayout(section: section)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(SuggestTagCell.self, forCellWithReuseIdentifier: SuggestTagCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let suggestedTags = ["사랑", "위로", "용기", "인생", "지혜", "철학", "감성"]
    private let maxTags = 3
    private var selectedTags: [String] = []

    // Save
    private let saveButton = SaveButton(title: "저장")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavigation()
        setupLayout()
        bindActions()
        configureForEdit()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupNavigation() {
        title = "문장 등록"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: AppFont.screenTitle.font,
            .foregroundColor: AppColor.textPrimary
        ]
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: AppIcon.close.sfSymbolName),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = AppColor.textSecondary
        navigationItem.rightBarButtonItem = closeButton
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        scrollView.addSubview(contentStack)

        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 24, right: 20))
            $0.width.equalTo(scrollView).offset(-40)
        }

        // Quote Section
        let quoteSection = UIStackView(arrangedSubviews: [quoteSectionLabel, quoteContainer, charCountLabel])
        quoteSection.axis = .vertical
        quoteSection.spacing = 10
        quoteSection.setCustomSpacing(6, after: quoteContainer)
        contentStack.addArrangedSubview(quoteSection)
        updateCharCount()

        quoteContainer.addSubview(quotePlaceholder)
        quoteContainer.addSubview(quoteTextView)

        quoteContainer.snp.makeConstraints {
            $0.height.equalTo(160)
        }

        quotePlaceholder.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
        }

        quoteTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-14)
        }

        // Page Section
        let pageSection = UIStackView(arrangedSubviews: [pageSectionLabel, pageTextField])
        pageSection.axis = .vertical
        pageSection.spacing = 10
        contentStack.addArrangedSubview(pageSection)

        pageTextField.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        // Tag Section
        tagInputContainer.addSubview(hashLabel)
        tagInputContainer.addSubview(tagTextField)

        hashLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        tagTextField.snp.makeConstraints {
            $0.leading.equalTo(hashLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        tagInputContainer.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        let rows = ceil(Double(suggestedTags.count) / 4.0)
        let gridHeight = rows * 36 + max(rows - 1, 0) * 8

        suggestCollectionView.snp.makeConstraints {
            $0.height.equalTo(gridHeight)
        }

        let tagSection = UIStackView(arrangedSubviews: [
            tagSectionLabel, tagInputContainer, tagHintLabel,
            suggestLabel, suggestCollectionView
        ])
        tagSection.axis = .vertical
        tagSection.spacing = 8
        tagSection.setCustomSpacing(12, after: tagHintLabel)
        tagSection.setCustomSpacing(12, after: suggestLabel)
        contentStack.addArrangedSubview(tagSection)
    }

    // MARK: - Tag Selection

    private func toggleTag(at index: Int) {
        let tag = suggestedTags[index]
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            if selectedTags.count >= maxTags {
                selectedTags.removeFirst()
            }
            selectedTags.append(tag)
        }
        suggestCollectionView.reloadData()
        updateTagHint()
    }

    private func addTagFromInput() {
        guard let text = tagTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              !selectedTags.contains(text) else { return }
        if selectedTags.count >= maxTags {
            selectedTags.removeFirst()
        }
        selectedTags.append(text)
        tagTextField.text = ""
        suggestCollectionView.reloadData()
        updateTagHint()
    }

    private func updateTagHint() {
        tagHintLabel.text = selectedTags.isEmpty
            ? "최대 3개까지 지정할 수 있어요"
            : "선택됨: \(selectedTags.map { "#\($0)" }.joined(separator: " ")) (\(selectedTags.count)/\(maxTags))"
    }

    private func updateCharCount() {
        let count = quoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        charCountLabel.text = "\(count)/\(maxCharacterCount)자"
        let isOver = count > maxCharacterCount
        charCountLabel.textColor = isOver ? AppColor.coral : AppColor.textTertiary
    }

    private func updateSaveButtonState() {
        let text = quoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !text.isEmpty && text.count <= maxCharacterCount
        saveButton.isEnabled = isValid
        saveButton.alpha = isValid ? 1.0 : 0.4
    }

    // MARK: - Bindings

    private func bindActions() {
        quoteTextView.delegate = self

        quoteTextView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.updateCharCount()
                self?.updateSaveButtonState()
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.saveQuote()
            })
            .disposed(by: disposeBag)

        tagTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.addTagFromInput()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Edit Mode

    private func configureForEdit() {
        guard let quote = existingQuote else { return }

        title = "문장 수정"
        saveButton.setTitle("수정", for: .normal)

        quoteTextView.text = quote.text
        quotePlaceholder.isHidden = true

        if let page = quote.pageNumber {
            pageTextField.text = "\(page)"
        }

        for tag in quote.tags {
            guard selectedTags.count < maxTags else { break }
            selectedTags.append(tag.name)
        }

        suggestCollectionView.reloadData()
        updateTagHint()
        updateCharCount()
        updateSaveButtonState()
    }

    // MARK: - Save

    private func saveQuote() {
        let text = quoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if let existing = existingQuote {
            guard !existing.isInvalidated else {
                dismiss(animated: true)
                return
            }
            let page = pageTextField.text.flatMap { Int($0) }
            quoteRepository.update(existing, text: text, pageNumber: page, tagNames: selectedTags)
        } else {
            let quote = Quote()
            quote.text = text
            quote.book = book

            if let pageText = pageTextField.text, let page = Int(pageText) {
                quote.pageNumber = page
            }

            if selectedTags.isEmpty {
                quoteRepository.save(quote)
            } else {
                quoteRepository.save(quote, tagNames: selectedTags)
            }
            bookRepository.markAsRecentlyUsed(book)
        }
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ManualQuoteEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        quotePlaceholder.isHidden = !textView.text.isEmpty
        updateCharCount()
        updateSaveButtonState()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ManualQuoteEntryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        suggestedTags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestTagCell.reuseId, for: indexPath) as! SuggestTagCell
        let tag = suggestedTags[indexPath.item]
        cell.configure(tag: tag, selected: selectedTags.contains(tag))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleTag(at: indexPath.item)
    }
}

// MARK: - Suggest Tag Cell

private final class SuggestTagCell: UICollectionViewCell {

    static let reuseId = "SuggestTagCell"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(tag: String, selected: Bool) {
        label.text = "# \(tag)"
        if selected {
            label.textColor = AppColor.accent
            contentView.backgroundColor = AppColor.accentLight
            contentView.layer.borderWidth = 0
        } else {
            label.textColor = AppColor.textSecondary
            contentView.backgroundColor = .clear
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = AppColor.border.cgColor
        }
    }
}
