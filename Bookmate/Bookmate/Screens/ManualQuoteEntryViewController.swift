import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RealmSwift

final class ManualQuoteEntryViewController: UIViewController {

    // MARK: - Dependencies

    private let book: Book
    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let headerView = CloseHeaderView(title: "문장 등록")

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

    private let suggestRow1 = UIStackView()
    private let suggestRow2 = UIStackView()

    private let suggestedTags = ["사랑", "위로", "용기", "인생", "지혜", "철학", "감성"]
    private let maxTags = 3
    private var selectedTags: [String] = []

    // Save
    private let saveButton = SaveButton(title: "저장")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupLayout()
        bindActions()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        scrollView.addSubview(contentStack)

        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 24, right: 20))
            $0.width.equalTo(scrollView).offset(-40)
        }

        // Quote Section
        let quoteSection = UIStackView(arrangedSubviews: [quoteSectionLabel, quoteContainer])
        quoteSection.axis = .vertical
        quoteSection.spacing = 10
        contentStack.addArrangedSubview(quoteSection)

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

        [suggestRow1, suggestRow2].forEach {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        let tagSection = UIStackView(arrangedSubviews: [
            tagSectionLabel, tagInputContainer, tagHintLabel,
            suggestLabel, suggestRow1, suggestRow2
        ])
        tagSection.axis = .vertical
        tagSection.spacing = 8
        tagSection.setCustomSpacing(12, after: tagHintLabel)
        tagSection.setCustomSpacing(12, after: suggestLabel)
        contentStack.addArrangedSubview(tagSection)

        setupSuggestedTags()
    }

    // MARK: - Suggested Tags

    private func setupSuggestedTags() {
        let row1Tags = Array(suggestedTags.prefix(4))
        let row2Tags = Array(suggestedTags.dropFirst(4))

        for tag in row1Tags {
            suggestRow1.addArrangedSubview(makeSuggestChip(tag))
        }
        for tag in row2Tags {
            suggestRow2.addArrangedSubview(makeSuggestChip(tag))
        }
    }

    private func makeSuggestChip(_ tag: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("# \(tag)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.setTitleColor(AppColor.textSecondary, for: .normal)
        btn.layer.cornerRadius = 100
        btn.layer.borderWidth = 1
        btn.layer.borderColor = AppColor.border.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)

        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.toggleTag(tag, fromChip: btn)
            })
            .disposed(by: disposeBag)

        return btn
    }

    private func toggleTag(_ tag: String, fromChip chip: UIButton) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
            applyChipStyle(chip, selected: false)
        } else {
            guard selectedTags.count < maxTags else { return }
            selectedTags.append(tag)
            applyChipStyle(chip, selected: true)
        }
        updateTagHint()
    }

    private func applyChipStyle(_ chip: UIButton, selected: Bool) {
        if selected {
            chip.setTitleColor(AppColor.accent, for: .normal)
            chip.backgroundColor = AppColor.accentLight
            chip.layer.borderWidth = 0
        } else {
            chip.setTitleColor(AppColor.textSecondary, for: .normal)
            chip.backgroundColor = .clear
            chip.layer.borderWidth = 1
            chip.layer.borderColor = AppColor.border.cgColor
        }
    }

    private func addTagFromInput() {
        guard let text = tagTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              selectedTags.count < maxTags,
              !selectedTags.contains(text) else { return }
        selectedTags.append(text)
        tagTextField.text = ""

        let allChips = (suggestRow1.arrangedSubviews + suggestRow2.arrangedSubviews).compactMap { $0 as? UIButton }
        for chip in allChips {
            let chipTag = chip.title(for: .normal)?.replacingOccurrences(of: "# ", with: "") ?? ""
            if chipTag == text {
                applyChipStyle(chip, selected: true)
            }
        }
        updateTagHint()
    }

    private func updateTagHint() {
        tagHintLabel.text = selectedTags.isEmpty
            ? "최대 3개까지 지정할 수 있어요"
            : "선택됨: \(selectedTags.map { "#\($0)" }.joined(separator: " ")) (\(selectedTags.count)/\(maxTags))"
    }

    // MARK: - Bindings

    private func bindActions() {
        headerView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        quoteTextView.delegate = self

        let hasText = quoteTextView.rx.text.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .share(replay: 1)

        hasText
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        hasText
            .map { $0 ? 1.0 : 0.4 }
            .bind(to: saveButton.rx.alpha)
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

    // MARK: - Save

    private func saveQuote() {
        let text = quoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

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
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ManualQuoteEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        quotePlaceholder.isHidden = !textView.text.isEmpty
    }
}
