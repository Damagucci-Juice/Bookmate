//
//  ViewController.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import SnapKit
import RealmSwift
import Kingfisher
import RxSwift
import RxCocoa

// MARK: - HomeViewController

class ViewController: UIViewController {

    private let bookRepository = BookRepository()
    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()

    // MARK: - Scroll & Content

    private let scrollView = UIScrollView()
    private let contentView = UIView()

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

    private let myQuotesButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.bookmark.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textPrimary
        return btn
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
        label.font = AppFont.quoteText.font
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
    private let recentBooksGrid: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupHierarchy()
        setupConstraints()
        loadTodayQuote()
        loadRecentBooks()
        myQuotesButton.addTarget(self, action: #selector(myQuotesTapped), for: .touchUpInside)
    }

    @objc private func myQuotesTapped() {
        let vc = QuoteListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadTodayQuote()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Greeting
        greetingSection.addSubview(logoLabel)
        greetingSection.addSubview(myQuotesButton)
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
        recentBooksSection.addSubview(recentBooksGrid)
        contentView.addSubview(recentBooksSection)

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
        logoLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        myQuotesButton.snp.makeConstraints {
            $0.centerY.equalTo(logoLabel)
            $0.trailing.equalToSuperview()
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
            $0.bottom.equalToSuperview().inset(24)
        }
        recentBooksHeaderStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        recentBooksGrid.snp.makeConstraints {
            $0.top.equalTo(recentBooksHeaderStack.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func loadTodayQuote() {
        quoteRepository.fetchAll()
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] quotes in
                guard let self else { return }
                if let random = quotes.randomElement() {
                    self.quoteBodyLabel.text = random.text
                    if let book = random.book {
                        self.quoteSourceLabel.text = "\(book.author) · \(book.title)"
                    } else {
                        self.quoteSourceLabel.text = nil
                    }
                } else {
                    self.quoteBodyLabel.text = "우리가 어떤 사람인지는 우리가 무엇을 반복해서 하느냐에 달려 있다. 그러므로 탁월함은 행위가 아니라 습관이다."
                    self.quoteSourceLabel.text = "아리스토텔레스 · 니코마코스 윤리학"
                }
            })
            .disposed(by: disposeBag)
    }

    private func loadRecentBooks() {
        bookRepository.fetchRecentlySearched()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                guard let self else { return }
                self.recentBooksGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
                let display = Array(books.prefix(4))
                if display.isEmpty {
                    self.recentBooksSection.isHidden = true
                } else {
                    self.recentBooksSection.isHidden = false
                    for rowStart in stride(from: 0, to: display.count, by: 2) {
                        let row = UIStackView()
                        row.axis = .horizontal
                        row.spacing = 10
                        row.distribution = .fillEqually

                        let first = display[rowStart]
                        row.addArrangedSubview(self.makeBookCard(from: first))

                        if rowStart + 1 < display.count {
                            let second = display[rowStart + 1]
                            row.addArrangedSubview(self.makeBookCard(from: second))
                        } else {
                            let spacer = UIView()
                            row.addArrangedSubview(spacer)
                        }

                        self.recentBooksGrid.addArrangedSubview(row)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func navigateToBookDetail(isbn: String) {
        let realm = Realm.configured()
        guard let searched = realm.objects(SearchedBook.self).filter("isbn == %@", isbn).first else { return }
        let book: Book
        if let existing = realm.objects(Book.self).filter("isbn == %@", isbn).first {
            book = existing
        } else {
            book = Book()
            book.title = searched.title
            book.author = searched.author
            book.isbn = searched.isbn
            try? realm.write { realm.add(book) }
        }
        let detailVC = BookDetailViewController(book: book)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func makeBookCard(from searched: SearchedBook) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor(red: 26/255, green: 25/255, blue: 24/255, alpha: 0.05).cgColor
        card.layer.shadowOpacity = 1
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        let isbn = searched.isbn
        let tap = UITapGestureRecognizer()
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToBookDetail(isbn: isbn)
            })
            .disposed(by: disposeBag)

        let coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 8
        coverImageView.backgroundColor = AppColor.border
        coverImageView.snp.makeConstraints {
            $0.height.equalTo(coverImageView.snp.width).multipliedBy(1.45)
        }

        if !searched.coverImageURL.isEmpty, let url = URL(string: searched.coverImageURL) {
            coverImageView.kf.setImage(with: url)
        }

        let titleLabel = UILabel()
        titleLabel.text = searched.title
        titleLabel.font = AppFont.filterChipActive.font
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 2

        let authorLabel = UILabel()
        authorLabel.text = searched.author
        authorLabel.font = AppFont.meta.font
        authorLabel.textColor = AppColor.textSecondary

        let vStack = UIStackView(arrangedSubviews: [coverImageView, titleLabel, authorLabel])
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

