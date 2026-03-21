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

        quoteRepository.save(quote)
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ManualQuoteEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        quotePlaceholder.isHidden = !textView.text.isEmpty
    }
}
