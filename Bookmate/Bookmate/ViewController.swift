//
//  ViewController.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import SnapKit

// MARK: - HomeViewController

class ViewController: UIViewController {

    // MARK: - Scroll & Content

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Greeting Section

    private let greetingSection = UIView()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "3월 19일 수요일"
        label.font = AppFont.caption.font
        label.textColor = AppColor.textTertiary
        return label
    }()
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 문장"
        label.font = AppFont.sectionTitle.font
        label.textColor = AppColor.textPrimary
        return label
    }()

    // MARK: - Quote Card

    private let quoteCard: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.card
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor(red: 26/255, green: 25/255, blue: 24/255, alpha: 0.05).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()
    private let quoteMarkLabel: UILabel = {
        let label = UILabel()
        label.text = "\u{201C}"
        label.font = AppFont.cardQuoteMark.font
        label.textColor = AppColor.coral
        return label
    }()
    private let quoteBodyLabel: UILabel = {
        let label = UILabel()
        label.text = "우리가 어떤 사람인지는 우리가 무엇을 반복해서 하느냐에 달려 있다. 그러므로 탁월함은 행위가 아니라 습관이다."
        label.font = AppFont.cardQuoteBody.font
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 0
        return label
    }()
    private let quoteDivider: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    private let quoteSourceLabel: UILabel = {
        let label = UILabel()
        label.text = "아리스토텔레스 · 니코마코스 윤리학"
        label.font = AppFont.caption.font
        label.textColor = AppColor.textTertiary
        return label
    }()

    // MARK: - Recent Books Section

    private let recentBooksSection = UIView()
    private let recentBooksHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    private let recentBooksLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색한 책"
        label.font = AppFont.screenTitle.font
        label.textColor = AppColor.textPrimary
        return label
    }()
    private let recentBooksRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Recommendation Section

    private let recommendSection = UIView()
    private let recommendHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    private let recommendLabel: UILabel = {
        let label = UILabel()
        label.text = "이런 문장은 어때요?"
        label.font = AppFont.screenTitle.font
        label.textColor = AppColor.textPrimary
        return label
    }()
    private let recommendMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.font = AppFont.caption.font
        button.setTitleColor(AppColor.textTertiary, for: .normal)
        return button
    }()
    private lazy var recommendCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 100)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(RecommendCell.self, forCellWithReuseIdentifier: RecommendCell.reuseID)
        cv.dataSource = self
        return cv
    }()

    private let recommendItems: [String] = [
        "완벽함은 더 이상 더할 것이 없을 때가 아니라, 더 이상 뺄 것이 없을 때 달성된다.",
        "당신이 멈추지 않는 한, 얼마나 천천히 가느냐는 문제가 되지 않는다.",
        "오늘 할 수 있는 일에 최선을 다하라. 그것이 내일을 위한 최선의 준비다."
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupHierarchy()
        setupConstraints()
        setupRecentBooks()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Greeting
        greetingSection.addSubview(dateLabel)
        greetingSection.addSubview(todayLabel)
        contentView.addSubview(greetingSection)

        // Quote card
        quoteCard.addSubview(quoteMarkLabel)
        quoteCard.addSubview(quoteBodyLabel)
        quoteCard.addSubview(quoteDivider)
        quoteCard.addSubview(quoteSourceLabel)
        contentView.addSubview(quoteCard)

        // Recent books
        recentBooksHeaderStack.addArrangedSubview(recentBooksLabel)
        recentBooksSection.addSubview(recentBooksHeaderStack)
        recentBooksSection.addSubview(recentBooksRow)
        contentView.addSubview(recentBooksSection)

        // Recommend
        recommendHeaderStack.addArrangedSubview(recommendLabel)
        recommendHeaderStack.addArrangedSubview(recommendMoreButton)
        recommendSection.addSubview(recommendHeaderStack)
        recommendSection.addSubview(recommendCollectionView)
        contentView.addSubview(recommendSection)
    }

    private func setupConstraints() {
        let sideInset: CGFloat = 20
        let sectionGap: CGFloat = 28

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        // MARK: Greeting Section
        greetingSection.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        dateLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        todayLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // MARK: Quote Card
        quoteCard.snp.makeConstraints {
            $0.top.equalTo(greetingSection.snp.bottom).offset(sectionGap)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        quoteMarkLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(28)
        }
        quoteBodyLabel.snp.makeConstraints {
            $0.top.equalTo(quoteMarkLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        quoteDivider.snp.makeConstraints {
            $0.top.equalTo(quoteBodyLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(1)
        }
        quoteSourceLabel.snp.makeConstraints {
            $0.top.equalTo(quoteDivider.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(32)
        }

        // MARK: Recent Books Section
        recentBooksSection.snp.makeConstraints {
            $0.top.equalTo(quoteCard.snp.bottom).offset(sectionGap)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        recentBooksHeaderStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        recentBooksRow.snp.makeConstraints {
            $0.top.equalTo(recentBooksHeaderStack.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // MARK: Recommend Section
        recommendSection.snp.makeConstraints {
            $0.top.equalTo(recentBooksSection.snp.bottom).offset(sectionGap)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
        recommendHeaderStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        recommendCollectionView.snp.makeConstraints {
            $0.top.equalTo(recommendHeaderStack.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(sideInset)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(116)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupRecentBooks() {
        let books: [(title: String, author: String)] = [
            ("니코마코스 윤리학", "아리스토텔레스"),
            ("미움받을 용기", "기시미 이치로"),
            ("아주 작은 습관의 힘", "제임스 클리어")
        ]
        for book in books {
            let card = makeBookCard(title: book.title, author: book.author)
            recentBooksRow.addArrangedSubview(card)
        }
    }

    private func makeBookCard(title: String, author: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor(red: 26/255, green: 25/255, blue: 24/255, alpha: 0.05).cgColor
        card.layer.shadowOpacity = 1
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        let coverPlaceholder = UIView()
        coverPlaceholder.backgroundColor = AppColor.border
        coverPlaceholder.layer.cornerRadius = 12
        coverPlaceholder.snp.makeConstraints { $0.height.equalTo(120) }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.filterChipActive.font
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 2

        let authorLabel = UILabel()
        authorLabel.text = author
        authorLabel.font = AppFont.meta.font
        authorLabel.textColor = AppColor.textSecondary

        let vStack = UIStackView(arrangedSubviews: [coverPlaceholder, titleLabel, authorLabel])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .fill

        card.addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        return card
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recommendItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendCell.reuseID, for: indexPath) as! RecommendCell
        cell.configure(with: recommendItems[indexPath.item])
        return cell
    }
}

// MARK: - RecommendCell

private final class RecommendCell: UICollectionViewCell {
    static let reuseID = "RecommendCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.accentLight
        view.layer.cornerRadius = 16
        return view
    }()
    private let sparkleLabel: UILabel = {
        let label = UILabel()
        label.text = "✦"
        label.font = AppFont.decorIcon.font
        label.textColor = AppColor.accent
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.recommendBody.font
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let hStack = UIStackView(arrangedSubviews: [sparkleLabel, quoteLabel])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .top
        containerView.addSubview(hStack)
        hStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with text: String) {
        quoteLabel.text = text
    }
}
