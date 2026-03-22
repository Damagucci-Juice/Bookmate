import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DetailSheetViewController: UIViewController {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let maxTags = 3
    private var selectedTags: [String] = []

    var initialPage: String?
    var onSave: ((_ page: String?, _ tags: [String]) -> Void)?

    private let suggestedTags = ["사랑", "위로", "용기", "인생", "지혜", "철학", "감성"]

    // MARK: - UI

//    private let handleBar: UIView = {
//        let v = UIView()
//        v.backgroundColor = AppColor.border
//        v.layer.cornerRadius = 2
//        return v
//    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "상세 정보"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = AppColor.textPrimary
        return l
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    private let pageSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "페이지 번호"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = AppColor.textSecondary
        return l
    }()

    private let pageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "42"
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = AppColor.textPrimary
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppColor.border.cgColor
        tf.keyboardType = .numberPad
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.rightViewMode = .always
        return tf
    }()

    private let pageHintLabel: UILabel = {
        let l = UILabel()
        l.text = "(선택사항)"
        l.font = .systemFont(ofSize: 12)
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.border
        return v
    }()

    private let tagSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "태그 이름"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = AppColor.textSecondary
        return l
    }()

    private let hashLabel: UILabel = {
        let l = UILabel()
        l.text = "#"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = AppColor.accent
        return l
    }()

    private let tagTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "태그 입력"
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = AppColor.textPrimary
        tf.returnKeyType = .done
        return tf
    }()

    private let tagInputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let tagHintLabel: UILabel = {
        let l = UILabel()
        l.text = "최대 3개까지 지정할 수 있어요"
        l.font = .systemFont(ofSize: 11)
        l.textColor = AppColor.textTertiary
        return l
    }()

    private let suggestLabel: UILabel = {
        let l = UILabel()
        l.text = "추천 태그"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = AppColor.textSecondary
        return l
    }()

    private let suggestRow1 = UIStackView()
    private let suggestRow2 = UIStackView()

    private let saveButton = PrimaryButton(title: "저장하기")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupSuggestedTags()
        bindActions()
        pageTextField.text = initialPage
    }

    // MARK: - Layout

    private func setupLayout() {
        // Handle bar
//        view.addSubview(handleBar)
//        handleBar.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(8)
//            $0.centerX.equalToSuperview()
//            $0.width.equalTo(40)
//            $0.height.equalTo(4)
//        }

        // Header
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        view.addSubview(headerStack)
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        closeButton.snp.makeConstraints {
            $0.size.equalTo(22)
        }

        // Page section
        view.addSubview(pageSectionLabel)
        pageSectionLabel.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        let pageRow = UIStackView(arrangedSubviews: [pageTextField, pageHintLabel])
        pageRow.axis = .horizontal
        pageRow.spacing = 10
        pageRow.alignment = .center
        view.addSubview(pageRow)
        pageTextField.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(48)
        }
        pageRow.snp.makeConstraints {
            $0.top.equalTo(pageSectionLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        // Divider
        view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(pageRow.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        // Tag section
        view.addSubview(tagSectionLabel)
        tagSectionLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        // Tag input
        view.addSubview(tagInputContainer)
        tagInputContainer.addSubview(hashLabel)
        tagInputContainer.addSubview(tagTextField)
        tagInputContainer.snp.makeConstraints {
            $0.top.equalTo(tagSectionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        hashLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        tagTextField.snp.makeConstraints {
            $0.leading.equalTo(hashLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        view.addSubview(tagHintLabel)
        tagHintLabel.snp.makeConstraints {
            $0.top.equalTo(tagInputContainer.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }

        // Suggested tags
        view.addSubview(suggestLabel)
        suggestLabel.snp.makeConstraints {
            $0.top.equalTo(tagHintLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        [suggestRow1, suggestRow2].forEach {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        view.addSubview(suggestRow1)
        suggestRow1.snp.makeConstraints {
            $0.top.equalTo(suggestLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }

        view.addSubview(suggestRow2)
        suggestRow2.snp.makeConstraints {
            $0.top.equalTo(suggestRow1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }

        // Save button
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.top.equalTo(suggestRow2.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    // MARK: - Suggested Tags

    private func setupSuggestedTags() {
        let row1Tags = Array(suggestedTags.prefix(4))
        let row2Tags = Array(suggestedTags.dropFirst(4))

        for tag in row1Tags {
            let chip = makeSuggestChip(tag)
            suggestRow1.addArrangedSubview(chip)
        }
        for tag in row2Tags {
            let chip = makeSuggestChip(tag)
            suggestRow2.addArrangedSubview(chip)
        }
    }

    private func makeSuggestChip(_ tag: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("# \(tag)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.setTitleColor(AppColor.textSecondary, for: .normal)
        btn.layer.cornerRadius = 100
        btn.layer.borderWidth = 1
        btn.layer.borderColor = AppColor.border.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)

        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addTag(tag, fromChip: btn)
            })
            .disposed(by: disposeBag)

        return btn
    }

    private func addTag(_ tag: String, fromChip chip: UIButton) {
        guard selectedTags.count < maxTags, !selectedTags.contains(tag) else { return }
        selectedTags.append(tag)

        // Highlight selected chip
        chip.setTitleColor(AppColor.accent, for: .normal)
        chip.backgroundColor = AppColor.accentLight
        chip.layer.borderWidth = 0

        updateTagHint()
    }

    private func addTagFromInput() {
        guard let text = tagTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty,
              selectedTags.count < maxTags,
              !selectedTags.contains(text) else { return }
        selectedTags.append(text)
        tagTextField.text = ""

        // Check if it matches a suggested tag and highlight
        let allChips = (suggestRow1.arrangedSubviews + suggestRow2.arrangedSubviews).compactMap { $0 as? UIButton }
        for chip in allChips {
            let chipTag = chip.title(for: .normal)?.replacingOccurrences(of: "# ", with: "") ?? ""
            if chipTag == text {
                chip.setTitleColor(AppColor.accent, for: .normal)
                chip.backgroundColor = AppColor.accentLight
                chip.layer.borderWidth = 0
            }
        }

        updateTagHint()
    }

    private func updateTagHint() {
        tagHintLabel.text = selectedTags.isEmpty
            ? "최대 3개까지 지정할 수 있어요"
            : "선택됨: \(selectedTags.map { "#\($0)" }.joined(separator: " ")) (\(selectedTags.count)/\(maxTags))"
    }

    // MARK: - Actions

    private func bindActions() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        tagTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.addTagFromInput()
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let page = self.pageTextField.text?.trimmingCharacters(in: .whitespaces)
                self.onSave?(page?.isEmpty == true ? nil : page, self.selectedTags)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
