import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RealmSwift

final class QuoteListViewController: UIViewController {

    // MARK: - Dependencies

    private let book: Book?
    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()

    private var quotes: [Quote] = []
    private var allTags: [String] = []
    private var selectedFilter: String? = nil  // nil = 전체

    // MARK: - Init

    /// book을 전달하면 해당 책의 문장만, nil이면 전체 문장을 표시
    init(book: Book? = nil) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let countBadge = CountBadgeView()

    private let filterScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        return sv
    }()

    private let filterStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "아직 수집한 문장이 없습니다"
        l.font = AppFont.body.font
        l.textColor = AppColor.textTertiary
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let fab = FABButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavBar()
        setupLayout()
        setupTableView()
        bindActions()
        loadQuotes()
    }

    // MARK: - Navigation Bar

    private func setupNavBar() {
        navigationItem.title = book != nil ? "수집한 문장" : "내 문장"

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
        searchButton.tintColor = AppColor.textSecondary
        navigationItem.rightBarButtonItem = searchButton
    }

    @objc private func searchTapped() {
        // TODO: 검색 기능 구현
    }

    // MARK: - Layout

    private var isAllBooksMode: Bool { book == nil }

    private func setupLayout() {
        view.addSubview(countBadge)
        view.addSubview(filterScrollView)
        filterScrollView.addSubview(filterStack)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        countBadge.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(filterScrollView)
        }

        filterScrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalTo(countBadge.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        filterStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(filterScrollView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(tableView)
        }

        if isAllBooksMode {
            view.addSubview(fab)
            fab.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            }
        }
    }

    // MARK: - Table View

    private func setupTableView() {
        tableView.register(QuoteListCell.self, forCellReuseIdentifier: QuoteListCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Filter Chips

    private func buildFilterChips() {
        filterStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let allChip = FilterChipView(title: "전체", active: selectedFilter == nil)
        allChip.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedFilter = nil
                self?.applyFilter()
            })
            .disposed(by: disposeBag)
        filterStack.addArrangedSubview(allChip)

        for tag in allTags {
            let chip = FilterChipView(title: tag, active: selectedFilter == tag)
            chip.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.selectedFilter = tag
                    self?.applyFilter()
                })
                .disposed(by: disposeBag)
            filterStack.addArrangedSubview(chip)
        }

        // "미지정" chip
        let untaggedChip = FilterChipView(title: "미지정", active: selectedFilter == "__untagged__")
        untaggedChip.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedFilter = "__untagged__"
                self?.applyFilter()
            })
            .disposed(by: disposeBag)
        filterStack.addArrangedSubview(untaggedChip)
    }

    private func applyFilter() {
        buildFilterChips()
        loadQuotes()
    }

    // MARK: - Data

    private func loadQuotes() {
        let base: Observable<[Quote]>

        if let book = book {
            base = quoteRepository.fetch(bookId: book.id)
        } else if selectedFilter == "__untagged__" {
            base = quoteRepository.fetchUntagged()
        } else if let tag = selectedFilter {
            base = quoteRepository.fetch(tagNames: [tag])
        } else {
            base = quoteRepository.fetchAll()
        }

        // 단일 책 모드에서도 태그 필터 적용
        let filtered: Observable<[Quote]>
        if book != nil, let filter = selectedFilter {
            if filter == "__untagged__" {
                filtered = base.map { $0.filter { $0.tags.isEmpty } }
            } else {
                filtered = base.map { quotes in
                    quotes.filter { q in q.tags.contains(where: { $0.name == filter }) }
                }
            }
        } else {
            filtered = base
        }

        filtered
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] quotes in
                guard let self else { return }
                self.quotes = quotes
                self.countBadge.update(count: quotes.count)
                self.emptyLabel.isHidden = !quotes.isEmpty
                self.tableView.reloadData()
                self.collectTags()
            })
            .disposed(by: disposeBag)
    }

    private func collectTags() {
        let realm = try! Realm(configuration: .defaultConfiguration)
        let tags = realm.objects(Tag.self)
            .filter("quotes.@count > 0")
            .map(\.name)
        let newTags = Array(tags)

        if newTags != allTags {
            allTags = newTags
            buildFilterChips()
        }
    }

    // MARK: - Actions

    private func bindActions() {
        guard isAllBooksMode else { return }

        fab.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentBookSelectionForAdd()
            })
            .disposed(by: disposeBag)
    }

    private func presentBookSelectionForAdd() {
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
            vc.modalPresentationStyle = .pageSheet
            self.present(vc, animated: true)
        }

        if let presentationController = sheet.sheetPresentationController {
            presentationController.detents = [.custom { _ in 250 }]
            presentationController.prefersGrabberVisible = true
            presentationController.preferredCornerRadius = 24
        }

        present(sheet, animated: true)
    }

    // MARK: - Tag Color Helper

    private func tagColor(for name: String) -> (text: UIColor, bg: UIColor) {
        switch name {
        case "자아":  return (AppColor.Tag.selfText, AppColor.Tag.selfBackground)
        case "사랑":  return (AppColor.Tag.loveText, AppColor.Tag.loveBackground)
        case "성장":  return (AppColor.Tag.growthText, AppColor.Tag.growthBackground)
        case "인생":  return (AppColor.Tag.lifeText, AppColor.Tag.lifeBackground)
        default:     return (AppColor.Tag.defaultText, AppColor.Tag.defaultBackground)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension QuoteListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuoteListCell.reuseId, for: indexPath) as! QuoteListCell
        let quote = quotes[indexPath.row]

        let bookInfo: String = {
            guard let b = quote.book else { return "" }
            return b.author.isEmpty ? b.title : "\(b.title) · \(b.author)"
        }()

        let firstTag = quote.tags.first
        let colors = firstTag.map { tagColor(for: $0.name) }

        cell.itemView.configure(
            quote: quote.text,
            bookInfo: bookInfo,
            tag: firstTag?.name,
            tagColor: colors?.text,
            tagBgColor: colors?.bg
        )

        cell.showDivider = indexPath.row < quotes.count - 1
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Quote List Cell

private final class QuoteListCell: UITableViewCell {

    static let reuseId = "QuoteListCell"

    let itemView = QuoteListItemView()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.border
        return v
    }()

    var showDivider: Bool = true {
        didSet { divider.isHidden = !showDivider }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(itemView)
        contentView.addSubview(divider)

        itemView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        divider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
