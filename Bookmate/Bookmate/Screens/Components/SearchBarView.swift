import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchBarView: UIView {

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "책 제목 또는 저자를 검색하세요"
        tf.font = AppFont.recommendBody.font
        tf.textColor = AppColor.textPrimary
        tf.returnKeyType = .search
        tf.autocorrectionType = .no
        return tf
    }()

    private let searchIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = AppIcon.search.image(pointSize: 20, weight: .regular)
        iv.tintColor = AppColor.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.card
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = AppColor.border.cgColor

        addSubview(searchIcon)
        addSubview(textField)

        snp.makeConstraints {
            $0.height.equalTo(48)
        }

        searchIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        textField.snp.makeConstraints {
            $0.leading.equalTo(searchIcon.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
