//
//  ViewController.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import SnapKit
import RealmSwift
import RxSwift
import RxCocoa

// MARK: - HomeViewController

class ViewController: UIViewController {

    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()
    private var loadedQuotes: [Quote] = []

    // MARK: - Content

    // MARK: - Greeting Section

    private let greetingSection = UIView()
    private let logoLabel: UILabel = {
        let label = UILabel()
        let text = "Bookmate"
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: AppFont.logo.font,
                .foregroundColor: AppColor.textPrimary,
                .kern: AppFont.Spacing.logoLetterSpacing
            ]
        )
        return label
    }()

    private let notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.bell.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    // MARK: - Curation Section (수집한 문장)

    private let curationHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    private let curationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "수집한 문장"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AppColor.textPrimary
        return label
    }()
    private let seeAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("전체보기", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(AppColor.accent, for: .normal)
        return btn
    }()

    private let quoteWheelView = QuoteWheelView()

    // MARK: - Empty State

    private let emptyStateView: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "home_empty_state"))
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "아직 수집한 문구가 없어요."
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = AppColor.textPrimary
        l.textAlignment = .center
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "첫 번째 문구를 채워볼까요?"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = AppColor.textSecondary
        l.textAlignment = .center
        return l
    }()

    private let emptyCtaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = AppColor.accent
        btn.layer.cornerRadius = 22

        var config = UIButton.Configuration.plain()
        config.title = "문구 수집 시작하기"
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return out
        }
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        config.image = UIImage(systemName: "plus", withConfiguration: iconConfig)
        config.imagePadding = 6
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        btn.configuration = config
        btn.tintColor = .white
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupHierarchy()
        setupConstraints()
        loadQuotes()
        seeAllButton.addTarget(self, action: #selector(seeAllQuotesTapped), for: .touchUpInside)
        emptyCtaButton.addTarget(self, action: #selector(emptyCtaTapped), for: .touchUpInside)
        quoteWheelView.onQuoteTapped = { [weak self] index in
            self?.openCardCustomization(at: index)
        }
    }

    private func openCardCustomization(at index: Int) {
        guard index < loadedQuotes.count else { return }
        let quote = loadedQuotes[index]
        guard let book = quote.book else { return }
        let tags = Array(quote.tags.map { $0.name })
        let page = quote.pageNumber.map { String($0) }
        let vc = CardCustomizationViewController(
            quoteText: quote.text,
            book: book,
            page: page,
            tags: tags,
            isExistingQuote: true,
            cardStyle: quote.cardStyle,
            quoteId: quote.id
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func emptyCtaTapped() {
        let bookSelection = BookSelectionViewController()
        bookSelection.onBookSelected = { [weak self] book in
            self?.presentAddQuoteSheet(for: book)
        }
        let nav = UINavigationController(rootViewController: bookSelection)
        present(nav, animated: true)
    }

    private func presentAddQuoteSheet(for book: Book) {
        let sheet = AddQuoteSheetViewController()

        sheet.onCameraScanTapped = { [weak self] in
            guard let self else { return }
            let vc = CameraCaptureViewController(book: book)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.setNavigationBarHidden(true, animated: false)
            self.present(nav, animated: true)
        }

        sheet.onManualEntryTapped = { [weak self] in
            guard let self else { return }
            let vc = ManualQuoteEntryViewController(book: book)
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

    @objc private func seeAllQuotesTapped() {
        let vc = QuoteListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadQuotes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupHierarchy() {
        // Greeting
        greetingSection.addSubview(logoLabel)
        greetingSection.addSubview(notificationButton)
        view.addSubview(greetingSection)

        // Curation (수집한 문장)
        curationHeaderStack.addArrangedSubview(curationTitleLabel)
        curationHeaderStack.addArrangedSubview(seeAllButton)
        view.addSubview(curationHeaderStack)
        view.addSubview(quoteWheelView)

        // Empty state
        let textStack = UIStackView(arrangedSubviews: [emptyTitleLabel, emptySubtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.alignment = .center

        let emptyStack = UIStackView(arrangedSubviews: [emptyImageView, textStack, emptyCtaButton])
        emptyStack.axis = .vertical
        emptyStack.spacing = 24
        emptyStack.alignment = .center

        emptyStateView.addSubview(emptyStack)
        emptyStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        view.addSubview(emptyStateView)
    }

    private func setupConstraints() {
        let sideInset: CGFloat = 20

        // MARK: Greeting Section
        greetingSection.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        logoLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        notificationButton.snp.makeConstraints {
            $0.centerY.equalTo(logoLabel)
            $0.trailing.equalToSuperview()
        }

        // MARK: Curation Header
        curationHeaderStack.snp.makeConstraints {
            $0.top.equalTo(greetingSection.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }

        // MARK: Quote Wheel — fills remaining screen
        quoteWheelView.snp.makeConstraints {
            $0.top.equalTo(curationHeaderStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }

        // MARK: Empty State — same area as wheel
        emptyStateView.snp.makeConstraints {
            $0.top.equalTo(greetingSection.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
        }
        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(240)
        }
    }

    // MARK: - Data

    private func loadQuotes() {
        quoteRepository.fetchAll()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] quotes in
                guard let self = self else { return }
                self.loadedQuotes = quotes
                let palette = AppColor.WheelCard.palette
                let items = quotes.enumerated().map { (index, quote) in
                    let bg = palette[index % palette.count]
                    let textColor = Self.textColorForBackground(bg)
                    return WheelQuoteItem(
                        text: quote.text,
                        bookTitle: quote.book?.title ?? "",
                        author: quote.book?.author ?? "",
                        page: quote.pageNumber,
                        backgroundColor: bg,
                        textColor: textColor
                    )
                }
                let isEmpty = items.isEmpty
                self.emptyStateView.isHidden = !isEmpty
                self.quoteWheelView.isHidden = isEmpty
                self.curationHeaderStack.isHidden = isEmpty

                if !isEmpty {
                    let previousIndex = self.quoteWheelView.currentIndex
                    self.quoteWheelView.configure(with: items)
                    self.quoteWheelView.currentIndex = previousIndex
                }
            })
            .disposed(by: disposeBag)
    }

    private static func mockQuotes() -> [WheelQuoteItem] {
        let data: [(String, String, String, Int?)] = [
            ("우리가 두려워해야 할 유일한 것은 두려움 그 자체이다. 용기란 두려움이 없는 것이 아니라 두려움보다 중요한 것이 있다고 판단하는 것이다.",
             "자유를 향한 긴 여정", "넬슨 만델라", 42),
            ("사막이 아름다운 것은 어딘가에 우물을 숨기고 있기 때문이야. 중요한 것은 눈에 보이지 않아. 오직 마음으로만 잘 볼 수 있지.",
             "어린 왕자", "생텍쥐페리", 78),
            ("인생이란 자전거를 타는 것과 같다. 균형을 잡으려면 계속 움직여야 한다. 상상력은 지식보다 중요하다.",
             "명언집", "아인슈타인", 15),
            ("진정한 발견의 여행은 새로운 풍경을 찾는 것이 아니라 새로운 눈을 갖는 것이다.",
             "잃어버린 시간을 찾아서", "프루스트", 234),
            ("새는 알에서 나오려고 투쟁한다. 알은 세계이다. 태어나려는 자는 하나의 세계를 깨뜨려야 한다.",
             "데미안", "헤르만 헤세", 106),
        ]
        let palette = AppColor.WheelCard.palette
        return data.enumerated().map { (index, item) in
            let bg = palette[index % palette.count]
            let textColor = textColorForBackground(bg)
            return WheelQuoteItem(text: item.0, bookTitle: item.1, author: item.2, page: item.3, backgroundColor: bg, textColor: textColor)
        }
    }

    private static func textColorForBackground(_ bg: UIColor) -> UIColor {
        if bg == AppColor.WheelCard.mutedGreen || bg == AppColor.WheelCard.dustyTeal {
            return .white
        }
        return AppColor.textPrimary
    }
}
