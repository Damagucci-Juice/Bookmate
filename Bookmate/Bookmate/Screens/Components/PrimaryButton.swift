import UIKit
import SnapKit

final class PrimaryButton: UIButton {

    init(title: String, icon: AppIcon? = nil) {
        super.init(frame: .zero)
        setupUI(title: title, icon: icon)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(title: String, icon: AppIcon?) {
        backgroundColor = AppColor.accent
        layer.cornerRadius = 14
        tintColor = .white

        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.buttonLabel.font
            return out
        }

        if let icon = icon {
            config.image = icon.image(pointSize: 18, weight: .semibold)
            config.imagePadding = 8
            config.imagePlacement = .leading
        }

        configuration = config

        snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
}
