import UIKit
import SnapKit

final class FilterChipView: UIButton {

    var isActive: Bool = false {
        didSet { updateAppearance() }
    }

    private let chipLabel: UILabel = {
        let l = UILabel()
        return l
    }()

    init(title: String, active: Bool = false) {
        super.init(frame: .zero)
        chipLabel.text = title
        isActive = active
        setupUI()
        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        clipsToBounds = true

        addSubview(chipLabel)
        chipLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    private func updateAppearance() {
        if isActive {
            backgroundColor = AppColor.textPrimary
            chipLabel.font = AppFont.filterChipActive.font
            chipLabel.textColor = .white
            layer.borderWidth = 0
        } else {
            backgroundColor = AppColor.border
            chipLabel.font = AppFont.filterChipInactive.font
            chipLabel.textColor = AppColor.textSecondary
            layer.borderWidth = 0
        }
    }
}
