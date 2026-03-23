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
        layer.cornerRadius = 100

        addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(9.5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }

    func update(count: Int) {
        countLabel.text = "\(count)"
    }
}
