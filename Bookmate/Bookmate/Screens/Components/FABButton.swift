import UIKit
import SnapKit

final class FABButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.accent
        layer.cornerRadius = 28
        tintColor = .white

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        setImage(UIImage(systemName: AppIcon.scan.sfSymbolName, withConfiguration: config), for: .normal)

        layer.shadowColor = AppColor.fabShadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        snp.makeConstraints {
            $0.size.equalTo(56)
        }
    }
}
