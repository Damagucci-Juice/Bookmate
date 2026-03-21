import UIKit
import SnapKit

final class CardStyleCircleView: UIView {

    var isSelectedStyle: Bool = false {
        didSet { layer.borderWidth = isSelectedStyle ? 3 : 0 }
    }

    init(colors: [UIColor]) {
        super.init(frame: .zero)
        setupUI(colors: colors)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(colors: [UIColor]) {
        layer.cornerRadius = 24
        layer.borderColor = AppColor.accent.cgColor
        clipsToBounds = true

        snp.makeConstraints {
            $0.size.equalTo(48)
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first(where: { $0 is CAGradientLayer })?.frame = bounds
    }
}
