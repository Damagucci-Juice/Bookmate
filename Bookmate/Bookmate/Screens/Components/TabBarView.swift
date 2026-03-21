import UIKit
import SnapKit

// MARK: - Tab Item Model

struct TabItem {
    let icon: AppIcon
    let title: String
}

// MARK: - TabBarView

final class TabBarView: UIView {

    var onTabSelected: ((Int) -> Void)?

    private var tabButtons: [UIButton] = []
    private var selectedIndex: Int = 0

    private let pillView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 36
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let tabStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()

    private let items: [TabItem]

    init(items: [TabItem]) {
        self.items = items
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.bg

        addSubview(pillView)
        pillView.addSubview(tabStack)

        pillView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(21)
            $0.trailing.equalToSuperview().offset(-21)
            $0.bottom.equalToSuperview().offset(-21)
        }

        tabStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        for (index, item) in items.enumerated() {
            let btn = makeTabButton(item: item, index: index)
            tabButtons.append(btn)
            tabStack.addArrangedSubview(btn)
        }

        updateSelection(index: 0)
    }

    private func makeTabButton(item: TabItem, index: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = index

        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 4
        config.image = item.icon.image(pointSize: 18, weight: .medium)
        config.title = item.title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.tabLabelInactive.font
            return out
        }
        btn.configuration = config
        btn.layer.cornerRadius = 26
        btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func tabTapped(_ sender: UIButton) {
        updateSelection(index: sender.tag)
        onTabSelected?(sender.tag)
    }

    func updateSelection(index: Int) {
        selectedIndex = index
        for (i, btn) in tabButtons.enumerated() {
            let isSelected = i == index
            btn.backgroundColor = isSelected ? AppColor.accent : .clear
            btn.tintColor = isSelected ? .white : AppColor.tabInactive

            var config = btn.configuration
            config?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = isSelected ? AppFont.tabLabelActive.font : AppFont.tabLabelInactive.font
                out.foregroundColor = isSelected ? .white : AppColor.tabInactive
                return out
            }
            btn.configuration = config
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 90)
    }
}
