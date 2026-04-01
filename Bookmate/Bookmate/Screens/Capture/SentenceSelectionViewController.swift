import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SentenceSelectionViewController: UIViewController {

    // MARK: - Properties

    private let sentences: [String]
    private let book: Book
    private let disposeBag = DisposeBag()
    private let quoteRepository = QuoteRepository()
    private let maxSelection = 3

    private var selectionRange: ClosedRange<Int>?

    // MARK: - Init

    init(sentences: [String], book: Book) {
        self.sentences = sentences
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    private let bottomContainer = UIView()

    private let continueButton: PrimaryButton = {
        let btn = PrimaryButton(title: "계속")
        btn.isEnabled = false
        btn.alpha = 0.4
        return btn
    }()

    private var bottomContainerBottom: Constraint?

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
        buildSentenceLines()
        bindActions()
        observeKeyboard()
    }

    // MARK: - Navigation Bar

    private func setupNavigation() {
        title = "문장 선택"

        let backImage = AppIcon.chevronLeft.image(pointSize: 18, weight: .medium)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = AppColor.textPrimary

        let closeImage = AppIcon.close.image(pointSize: 18, weight: .medium)
        let closeItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeItem.tintColor = AppColor.textSecondary

        navigationItem.rightBarButtonItem = closeItem
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func closeTapped() {
        guard let navController = navigationController else { return }
        if let cameraVC = navController.viewControllers.first(where: { $0 is CameraCaptureViewController }) {
            navController.popToViewController(cameraVC, animated: true)
        } else {
            navController.popToRootViewController(animated: true)
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        view.addSubview(bottomContainer)

        bottomContainer.addSubview(continueButton)

        bottomContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            bottomContainerBottom = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        continueButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-16)
        }

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomContainer.snp.top)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20))
            $0.width.equalTo(scrollView).offset(-40)
        }

    }

    // MARK: - Sentence Lines

    private func buildSentenceLines() {
        for (index, sentence) in sentences.enumerated() {
            let lineView = SentenceLineView()
            lineView.configure(text: sentence, state: .unselected)
            lineView.tag = index
            lineView.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer()
            lineView.addGestureRecognizer(tap)

            tap.rx.event
                .subscribe(onNext: { [weak self] _ in
                    self?.toggleSelection(at: index)
                })
                .disposed(by: disposeBag)

            contentStack.addArrangedSubview(lineView)
        }
    }

    private func toggleSelection(at index: Int) {
        guard let range = selectionRange else {
            // No selection yet — start new range
            selectionRange = index...index
            updateLineAppearances()
            return
        }

        if range.contains(index) {
            // Tap inside range
            if range.count == 1 {
                // Only one selected — deselect all
                selectionRange = nil
            } else if index == range.lowerBound {
                // Shrink from start
                selectionRange = (index + 1)...range.upperBound
            } else if index == range.upperBound {
                // Shrink from end
                selectionRange = range.lowerBound...(index - 1)
            } else {
                // Middle tap — trim from tapped line onward
                selectionRange = range.lowerBound...(index - 1)
            }
        } else {
            // Tap outside range — extend to include, fill gap
            let newLower = min(range.lowerBound, index)
            let newUpper = max(range.upperBound, index)
            let newRange = newLower...newUpper
            guard newRange.count <= maxSelection else { return }
            selectionRange = newRange
        }
        updateLineAppearances()
    }

    private func updateLineAppearances() {
        let count = selectionRange?.count ?? 0
        let hasSelection = count > 0
        continueButton.isEnabled = hasSelection
        continueButton.alpha = hasSelection ? 1.0 : 0.4
        continueButton.configuration?.title = hasSelection
            ? "계속하기(\(count)/\(maxSelection))"
            : "계속"

        var adjacentIndices: Set<Int> = []
        if let range = selectionRange, range.count < maxSelection {
            let above = range.lowerBound - 1
            let below = range.upperBound + 1
            if above >= 0 { adjacentIndices.insert(above) }
            if below < sentences.count { adjacentIndices.insert(below) }
        }

        for (i, arrangedView) in contentStack.arrangedSubviews.enumerated() {
            guard let lineView = arrangedView as? SentenceLineView else { continue }

            let state: SentenceLineView.SelectionState
            if selectionRange?.contains(i) == true {
                state = .selected
            } else if adjacentIndices.contains(i) {
                state = .adjacent
            } else {
                state = .unselected
            }

            lineView.configure(text: sentences[i], state: state)
        }
    }

    // MARK: - Keyboard

    private func observeKeyboard() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .subscribe(onNext: { [weak self] info in
                guard let self,
                      let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
                let keyboardHeight = frame.height - self.view.safeAreaInsets.bottom
                self.bottomContainerBottom?.update(offset: -keyboardHeight)
                UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .compactMap { $0.userInfo }
            .subscribe(onNext: { [weak self] info in
                guard let self,
                      let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
                self.bottomContainerBottom?.update(offset: 0)
                UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    private func bindActions() {
        continueButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let selectedText = self.selectionRange.map { range in
                    range.map { self.sentences[$0] }.joined(separator: " ")
                } ?? ""

                let sheet = DetailSheetViewController()
                sheet.initialPage = nil
                sheet.onSave = { [weak self] page, tags in
                    guard let self else { return }

                    sheet.dismiss(animated: true) {
                        let cardVC = CardCustomizationViewController(
                            quoteText: selectedText,
                            book: self.book,
                            page: page,
                            tags: tags
                        )
                        self.navigationController?.pushViewController(cardVC, animated: true)
                    }
                }

                if let presentationController = sheet.sheetPresentationController {
                    presentationController.detents = [.medium(), .large()]
                    presentationController.prefersGrabberVisible = true
                    presentationController.preferredCornerRadius = 24
                }

                self.present(sheet, animated: true)
            })
            .disposed(by: disposeBag)

        // Dismiss keyboard on scroll
        scrollView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}
