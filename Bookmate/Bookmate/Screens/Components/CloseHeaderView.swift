import UIKit
import SnapKit

final class CloseHeaderView: UIView {

    var onCloseTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.screenTitle.font
        l.textColor = AppColor.textPrimary
        return l
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(closeButton)

        snp.makeConstraints {
            $0.height.equalTo(52)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    func updateTitle(_ title: String) {
        titleLabel.text = title
    }

    @objc private func closeTapped() { onCloseTapped?() }
}
