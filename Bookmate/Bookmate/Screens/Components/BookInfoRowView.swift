import UIKit
import SnapKit
import Kingfisher

final class BookInfoRowView: UIView {

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppColor.card
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let bookTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = AppColor.textPrimary
        l.numberOfLines = 1
        return l
    }()

    private let authorLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.caption.font
        l.textColor = AppColor.textSecondary
        return l
    }()

    private let pageLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.meta.font
        l.textColor = AppColor.textTertiary
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let infoStack = UIStackView(arrangedSubviews: [bookTitleLabel, authorLabel, pageLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [coverImageView, infoStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center

        addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        coverImageView.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(84)
        }
    }

    func configure(title: String, author: String, page: String? = nil, coverURL: URL? = nil) {
        bookTitleLabel.text = title
        authorLabel.text = author
        pageLabel.text = page
        pageLabel.isHidden = page == nil

        if let url = coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }
}
