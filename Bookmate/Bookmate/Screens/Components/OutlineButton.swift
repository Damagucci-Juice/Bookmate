import UIKit
import SnapKit

final class OutlineButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(title: String) {
        backgroundColor = .clear
        layer.cornerRadius = 14
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor

        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = AppFont.buttonLabel.font
            return out
        }
        configuration = config

        snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
}
