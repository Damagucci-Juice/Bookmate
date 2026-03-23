import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift
import AVFoundation

final class BookDetailViewController: UIViewController {

    // MARK: - Dependencies

    private let disposeBag = DisposeBag()
    private let bookRepository = BookRepository()
    private let quoteRepository = QuoteRepository()
    private let book: Book
    private var quotes: [Quote] = []

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
    private let memoSectionLabel = SectionLabelView(text: "메모")
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

    // Save Button
    private let saveButton = SaveButton(title: "문장 담기")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavBar()
        setupLayout()
        configureBookInfo()
        bindActions()
        loadQuotes()
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
        view.addSubview(saveButton)
        scrollView.addSubview(contentStack)

        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
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

        let quoteSection = UIStackView(arrangedSubviews: [quoteSectionLabelRow, quoteCard])
        quoteSection.axis = .vertical
        quoteSection.spacing = 10
        contentStack.addArrangedSubview(quoteSection)
    }

    // MARK: - Configure Book Info (from Model)

    private func configureBookInfo() {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let memoText = memoInputView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        bookRepository.updateMemo(memoText, for: book)
    }

    // MARK: - Actions

    private func bindActions() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentAddQuoteSheet()
            })
            .disposed(by: disposeBag)

        quoteMoreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let vc = QuoteListViewController(book: self.book)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func presentAddQuoteSheet() {
        let sheet = AddQuoteSheetViewController()

        sheet.onCameraScanTapped = { [weak self] in
            guard let self else { return }
            self.requestCameraAccessAndPresent()
        }

        sheet.onManualEntryTapped = { [weak self] in
            guard let self else { return }
            let vc = ManualQuoteEntryViewController(book: self.book)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }

        if let presentationController = sheet.sheetPresentationController {
            presentationController.detents = [.custom { _ in 250 }]
            presentationController.prefersGrabberVisible = true
            presentationController.preferredCornerRadius = 24
        }

        present(sheet, animated: true)
    }

    private func requestCameraAccessAndPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCameraFlow()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.presentCameraFlow()
                    } else {
                        self.showCameraAccessDeniedAlert()
                    }
                }
            }
        default:
            showCameraAccessDeniedAlert()
        }
    }

    private func presentCameraFlow() {
        let vc = CameraCaptureViewController(book: book)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.setNavigationBarHidden(true, animated: false)
        present(nav, animated: true)
    }

    private func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "카메라 접근 권한 필요",
            message: "설정에서 카메라 접근을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
