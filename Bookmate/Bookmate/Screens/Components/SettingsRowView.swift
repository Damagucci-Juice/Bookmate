import UIKit
import SnapKit

final class SettingsRowView: UIView {

    private let labelView: UILabel = {
        let l = UILabel()
        l.font = AppFont.body.font
        l.textColor = AppColor.textPrimary
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.body.font
        l.textColor = AppColor.textSecondary
        return l
    }()

    init(label: String, value: String = "") {
        super.init(frame: .zero)
        labelView.text = label
        valueLabel.text = value
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(labelView)
        addSubview(valueLabel)

        snp.makeConstraints {
            $0.height.equalTo(52)
        }

        labelView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    func update(value: String) {
        valueLabel.text = value
    }
}
