import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift

final class BookSelectionViewController: UIViewController {

    /// 책 선택 콜백 — 설정되면 BookDetail 대신 콜백 호출 후 dismiss
    var onBookSelected: ((Book) -> Void)?

    private let disposeBag = DisposeBag()
    private var recentBooksDisposable: Disposable?
    private let bookService = NaverBookService()
    private let bookRepository = BookRepository()

    private enum ScreenState {
        case recent
        case searching
    }
    private var state: ScreenState = .recent

    private var recentBooks: [SearchedBook] = []
    private var searchResults: [BookItem] = []

    // Pagination state
    private var currentQuery: String = ""
    private var currentStart: Int = 1
    private let pageSize: Int = 20
    private var totalResults: Int = 0
    private var isLoadingMore: Bool = false

    // MARK: - UI

    private let searchContainer: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let searchIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = AppIcon.search.image(pointSize: 18, weight: .medium)
        iv.tintColor = AppColor.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "책 제목 또는 저자를 검색하세요"
        tf.font = AppFont.body.font
        tf.textColor = AppColor.textPrimary
        tf.returnKeyType = .search
        tf.autocorrectionType = .no
        return tf
    }()

    private let searchClearButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textTertiary
        btn.isHidden = true
        return btn
    }()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색한 책"
        label.font = AppFont.caption.font
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("지우기", for: .normal)
        btn.titleLabel?.font = AppFont.caption.font
        btn.setTitleColor(AppColor.textTertiary, for: .normal)
        return btn
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .onDrag
        tv.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseID)
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "도서 선택"
        navigationItem.title = "도서 선택"
        view.backgroundColor = AppColor.bg
        setupLayout()
        setupTableView()
        bindSearch()
        loadRecentBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if state == .recent {
            loadRecentBooks()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchIconView)
        searchContainer.addSubview(searchTextField)
        searchContainer.addSubview(searchClearButton)

        let headerStack = UIStackView(arrangedSubviews: [sectionTitleLabel, clearButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        view.addSubview(headerStack)
        view.addSubview(tableView)

        searchContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        searchIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(18)
        }
        searchTextField.snp.makeConstraints {
            $0.leading.equalTo(searchIconView.snp.trailing).offset(12)
            $0.trailing.equalTo(searchClearButton.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
        }
        searchClearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(28)
        }
        headerStack.snp.makeConstraints {
            $0.top.equalTo(searchContainer.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - TableView

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Rx Bindings

    private func bindSearch() {
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                guard let self else { return }
                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.switchToRecent()
                } else {
                    self.performSearch(query: query)
                }
            })
            .disposed(by: disposeBag)

        searchTextField.rx.text.orEmpty
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .bind(to: searchClearButton.rx.isHidden)
            .disposed(by: disposeBag)

        searchClearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.searchTextField.text = ""
                self.searchTextField.sendActions(for: .valueChanged)
                self.switchToRecent()
            })
            .disposed(by: disposeBag)

        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.bookRepository.clearRecentSearches()
                ImageCache.default.clearMemoryCache()
                ImageCache.default.clearDiskCache()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Data

    private func loadRecentBooks() {
        recentBooksDisposable?.dispose()
        recentBooksDisposable = bookRepository.fetchRecentlySearched()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] books in
                guard let self, self.state == .recent else { return }
                self.recentBooks = books
                self.tableView.reloadData()
            })
    }

    private func switchToRecent() {
        state = .recent
        searchResults = []
        tableView.reloadData()
        sectionTitleLabel.text = "최근 검색한 책"
        clearButton.isHidden = false
        loadRecentBooks()
    }

    private func performSearch(query: String) {
        state = .searching
        sectionTitleLabel.text = "검색 결과"
        clearButton.isHidden = true

        // Reset pagination state for new search
        currentQuery = query
        currentStart = 1
        totalResults = 0
        isLoadingMore = false
        searchResults = []
        tableView.reloadData()

        bookService.search(query: query, display: pageSize, start: currentStart)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self, self.state == .searching else { return }
                self.searchResults = response.items
                self.totalResults = response.total
                self.sectionTitleLabel.text = "검색 결과 \(response.total)건"
                self.tableView.reloadData()
            }, onError: { [weak self] _ in
                self?.searchResults = []
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func loadNextPage() {
        guard !isLoadingMore,
              searchResults.count < totalResults,
              state == .searching else { return }

        isLoadingMore = true
        let nextStart = searchResults.count + 1

        bookService.search(query: currentQuery, display: pageSize, start: nextStart)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                let startIndex = self.searchResults.count
                self.searchResults.append(contentsOf: response.items)
                self.isLoadingMore = false

                let indexPaths = (startIndex..<self.searchResults.count).map {
                    IndexPath(row: $0, section: 0)
                }
                self.tableView.insertRows(at: indexPaths, with: .none)
            }, onError: { [weak self] _ in
                self?.isLoadingMore = false
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension BookSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state == .recent ? recentBooks.count : searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseID, for: indexPath) as! BookCell
        switch state {
        case .recent:
            let book = recentBooks[indexPath.row]
            cell.configure(title: book.title, author: book.author, coverURL: book.coverImageURL)
        case .searching:
            let item = searchResults[indexPath.row]
            cell.configure(title: item.cleanTitle, author: item.authors.joined(separator: ", "), coverURL: item.image)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch state {
        case .recent:
            let searched = recentBooks[indexPath.row]
            bookRepository.markAsRecentlySearched(searched)
            let book = findOrCreateBook(from: searched)
            handleBookSelected(book)
        case .searching:
            let item = searchResults[indexPath.row]
            bookRepository.addToSearchHistory(from: item)
            let book = bookRepository.findOrCreate(from: item)
            // Download cover image if not already stored
            if book.coverImageData == nil, let url = URL(string: item.image) {
                let options: KingfisherOptionsInfo = [
                    .diskCacheExpiration(.days(7)),
                    .memoryCacheExpiration(.days(1))
                ]
                KingfisherManager.shared.retrieveImage(with: url, options: options) { [weak self] result in
                    if case .success(let value) = result,
                       let data = value.image.pngData() {
                        self?.bookRepository.updateCoverImage(data, for: book)
                    }
                }
            }
            handleBookSelected(book)
        }
    }

    private func findOrCreateBook(from searched: SearchedBook) -> Book {
        let realm = Realm.configured()
        if let existing = realm.objects(Book.self).filter("isbn == %@", searched.isbn).first {
            return existing
        }
        let book = Book()
        book.title = searched.title
        book.author = searched.author
        book.isbn = searched.isbn
        try? realm.write { realm.add(book) }
        return book
    }

    private func handleBookSelected(_ book: Book) {
        if let onBookSelected {
            dismiss(animated: true) {
                onBookSelected(book)
            }
        } else {
            let detailVC = BookDetailViewController(book: book)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        78
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard state == .searching else { return }
        // Trigger load when user approaches the last 3 cells
        if indexPath.row >= searchResults.count - 3 {
            loadNextPage()
        }
    }
}

// MARK: - BookCell

private final class BookCell: UITableViewCell {

    static let reuseID = "BookCell"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.backgroundColor = AppColor.border
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 1
        return label
    }()

    private let chevronView: UIImageView = {
        let iv = UIImageView()
        iv.image = AppIcon.chevronRight.image(pointSize: 14, weight: .medium)
        iv.tintColor = AppColor.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        let metaStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
        metaStack.axis = .vertical
        metaStack.spacing = 4

        contentView.addSubview(coverImageView)
        contentView.addSubview(metaStack)
        contentView.addSubview(chevronView)

        coverImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(62)
        }
        metaStack.snp.makeConstraints {
            $0.leading.equalTo(coverImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(chevronView.snp.leading).offset(-12)
        }
        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(14)
        }
    }

    func configure(title: String, author: String, coverData: Data? = nil, coverURL: String? = nil) {
        titleLabel.text = title
        authorLabel.text = author

        if let data = coverData, let image = UIImage(data: data) {
            coverImageView.image = image
        } else if let urlString = coverURL, !urlString.isEmpty, let url = URL(string: urlString) {
            let processor = DownsamplingImageProcessor(size: CGSize(width: 44 * 3, height: 62 * 3))
            coverImageView.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .diskCacheExpiration(.days(7)),
                    .memoryCacheExpiration(.days(1))
                ]
            )
        } else {
            coverImageView.image = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
    }
}
