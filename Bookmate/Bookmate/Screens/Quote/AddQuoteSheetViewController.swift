import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddQuoteSheetViewController: UIViewController {

    // MARK: - Callback

    var onCameraScanTapped: (() -> Void)?
    var onManualEntryTapped: (() -> Void)?

    private let disposeBag = DisposeBag()

    // MARK: - UI
//
//    private let handle: UIView = {
//        let v = UIView()
//        v.backgroundColor = AppColor.border
//        v.layer.cornerRadius = 2
//        return v
//    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "문장 추가"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = AppColor.textPrimary
        return l
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    private let cameraScanCard = AddQuoteOptionCard(
        icon: AppIcon.scan.sfSymbolName,
        title: "카메라로 스캔",
        desc: "책 페이지를 촬영하여 텍스트를 인식합니다"
    )

    private let manualEntryCard = AddQuoteOptionCard(
        icon: "pencil.line",
        title: "직접 입력",
        desc: "문장을 직접 타이핑하여 등록합니다"
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card
        setupLayout()
        bindActions()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(cameraScanCard)
        view.addSubview(manualEntryCard)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(24)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(32)
        }

        cameraScanCard.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        manualEntryCard.snp.makeConstraints {
            $0.top.equalTo(cameraScanCard.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    // MARK: - Bindings

    private func bindActions() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        cameraScanCard.rx.tapGesture
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onCameraScanTapped?()
                }
            })
            .disposed(by: disposeBag)

        manualEntryCard.rx.tapGesture
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onManualEntryTapped?()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Option Card View

final class AddQuoteOptionCard: UIView {

    fileprivate let tapSubject = PublishSubject<Void>()

    init(icon: String, title: String, desc: String) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title, desc: desc)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() {
        tapSubject.onNext(())
    }

    private func setupUI(icon: String, title: String, desc: String) {
        backgroundColor = AppColor.bg
        layer.cornerRadius = 16

        // Icon wrapper
        let iconView = UIView()
        iconView.backgroundColor = AppColor.accentLight
        iconView.layer.cornerRadius = 12

        let iconImage = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImage.image = UIImage(systemName: icon, withConfiguration: config)
        iconImage.tintColor = AppColor.accent
        iconImage.contentMode = .scaleAspectFit
        iconView.addSubview(iconImage)

        iconView.snp.makeConstraints { $0.size.equalTo(48) }
        iconImage.snp.makeConstraints { $0.center.equalToSuperview(); $0.size.equalTo(24) }

        // Text
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary

        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = AppColor.textSecondary
        descLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        // Chevron
        let chevron = UIImageView()
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        chevron.image = UIImage(systemName: AppIcon.chevronRight.sfSymbolName, withConfiguration: chevronConfig)
        chevron.tintColor = AppColor.textTertiary
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconView, textStack, chevron])
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center

        addSubview(row)
        row.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: AddQuoteOptionCard {
    var tapGesture: Observable<Void> {
        base.tapSubject.asObservable()
    }
}
