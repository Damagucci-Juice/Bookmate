import UIKit
import SnapKit

final class MemoInputView: UIView {

    var text: String {
        get { textView.text }
        set { textView.text = newValue; placeholderLabel.isHidden = !newValue.isEmpty }
    }

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "이 문장에 대한 메모를 남겨보세요..."
        l.font = AppFont.recommendBody.font
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = AppFont.recommendBody.font
        tv.textColor = AppColor.textPrimary
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
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

        addSubview(placeholderLabel)
        addSubview(textView)

        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
        }

        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-14)
        }

        snp.makeConstraints {
            $0.height.equalTo(80)
        }

        textView.delegate = self
    }
}

extension MemoInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
