import UIKit
import SnapKit

final class TagChipView: UIView {

    var onRemoveTapped: (() -> Void)?

    private let tagLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.meta.font
        return l
    }()

    private let removeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        return btn
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()

    init(title: String, showRemove: Bool = false) {
        super.init(frame: .zero)
        tagLabel.text = title
        removeButton.isHidden = !showRemove
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 100
        clipsToBounds = true

        contentStack.addArrangedSubview(tagLabel)
        contentStack.addArrangedSubview(removeButton)
        addSubview(contentStack)

        contentStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(10)
        }

        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)

        configure(title: tagLabel.text ?? "", textColor: AppColor.accent, bgColor: AppColor.accentLight)
    }

    @objc private func removeTapped() { onRemoveTapped?() }

    func configure(title: String, textColor: UIColor = AppColor.accent, bgColor: UIColor = AppColor.accentLight) {
        tagLabel.text = title
        tagLabel.textColor = textColor
        removeButton.tintColor = textColor
        backgroundColor = bgColor
    }
}
