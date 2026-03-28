import UIKit
import SnapKit
import Kingfisher

final class RecommendBookCard: UIView {

    var onTap: (() -> Void)?

    // MARK: - UI

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = AppColor.border
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = AppColor.textPrimary
        l.numberOfLines = 1
        return l
    }()

    private let authorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = AppColor.textSecondary
        l.numberOfLines = 1
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)

        coverImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }

        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Configure
    func configure(title: String, author: String, coverURL: String?) {
        titleLabel.text = title
        authorLabel.text = author

        if let urlString = coverURL, let url = URL(string: urlString) {
            coverImageView.kf.setImage(with: url, options: [
                .scaleFactor(UIScreen.main.scale),
                .diskCacheExpiration(.days(7)),
                .memoryCacheExpiration(.days(1))
            ])
        } else {
            coverImageView.image = nil
        }
    }

    @objc private func tapped() {
        onTap?()
    }
}
