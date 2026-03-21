import UIKit
import SnapKit

final class ShareOptionItemView: UIView {

    private let circleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#333333")
        v.layer.cornerRadius = 24
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.56)
        l.textAlignment = .center
        return l
    }()

    init(icon: AppIcon, title: String) {
        super.init(frame: .zero)
        iconView.image = icon.image(pointSize: 20, weight: .medium)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [circleView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        circleView.addSubview(iconView)
        circleView.snp.makeConstraints {
            $0.size.equalTo(48)
        }
        iconView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(20)
        }

        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
