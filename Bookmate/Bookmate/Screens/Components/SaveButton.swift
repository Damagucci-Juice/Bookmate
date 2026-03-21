import UIKit
import SnapKit

final class SaveButton: UIButton {

    init(title: String = "문장 저장하기") {
        super.init(frame: .zero)
        setupUI(title: title)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(title: String) {
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
        configuration = config

        snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
}
