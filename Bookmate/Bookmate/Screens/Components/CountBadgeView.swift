import UIKit
import SnapKit

final class CountBadgeView: UIView {

    private let countLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    init(count: Int = 0) {
        super.init(frame: .zero)
        setupUI()
        update(count: count)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.accent
        clipsToBounds = true

        addSubview(countLabel)
        snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(60)
        }

        countLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(9.5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    func update(count: Int) {
        countLabel.text = "\(count)"
    }
}
