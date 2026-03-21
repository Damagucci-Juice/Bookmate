import UIKit
import SnapKit

final class DividerView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.border
        snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
