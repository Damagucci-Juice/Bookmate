import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Vision

final class TextRecognitionViewController: UIViewController {

    // MARK: - Properties

    private let imageData: Data
    private let book: Book
    private let disposeBag = DisposeBag()

    private let imageOCR = OCR()
    private var languageCorrection = true
    private var selectedRecognitionLevel = "Accurate"
    private var selectedLanguage = Locale.Language(identifier: "ko")
    private let recognitionLevels = ["Fast", "Accurate"]
    private var supportedLanguages: [Locale.Language] = []

    // MARK: - Init

    init(imageData: Data, book: Book) {
        self.imageData = imageData
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    // Photo Section
    private let photoContainer: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        return v
    }()

    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    private let boxOverlayView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        return v
    }()

    // Settings Card
    private let settingsCard: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.card
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = AppColor.border.cgColor
        return v
    }()

    private let accuracySegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["빠름", "정확"])
        sc.selectedSegmentIndex = 1
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13, weight: .medium)], for: .normal)
        sc.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.white
        ], for: .selected)
        sc.selectedSegmentTintColor = AppColor.accent
        sc.backgroundColor = UIColor(hex: "#F0EFEC")
        return sc
    }()

    private let languageCorrectionSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        s.onTintColor = AppColor.accent
        return s
    }()

    private let languageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(AppColor.textPrimary, for: .normal)
        btn.backgroundColor = UIColor(hex: "#F0EFEC")
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return btn
    }()

    // Action Button
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("텍스트 확인하기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColor.accent
        btn.layer.cornerRadius = 14
        return btn
    }()

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupNavigation()

        photoImageView.image = UIImage(data: imageData)
        supportedLanguages = imageOCR.request.supportedRecognitionLanguages

        setupLayout()
        bindActions()
        updateLanguageButtonTitle()
        runOCR()
    }

    private func setupNavigation() {
        title = "텍스트 인식"

        let backImage = AppIcon.chevronLeft.image(pointSize: 18, weight: .medium)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(navBackTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = AppColor.textPrimary
    }

    @objc private func navBackTapped() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !imageOCR.observations.isEmpty {
            drawBoundingBoxes()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        // Photo Section
        view.addSubview(photoContainer)
        photoContainer.addSubview(photoImageView)
        photoContainer.addSubview(boxOverlayView)

        photoContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(300)
        }
        photoImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        boxOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Settings Card
        view.addSubview(settingsCard)
        settingsCard.snp.makeConstraints {
            $0.top.equalTo(photoContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let settingsStack = UIStackView()
        settingsStack.axis = .vertical
        settingsCard.addSubview(settingsStack)
        settingsStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        // Row 1: 인식 정확도
        let accuracyRow = makeSettingRow(label: "인식 정확도", control: accuracySegmentedControl)
        accuracySegmentedControl.snp.makeConstraints { $0.width.equalTo(120) }

        // Row 2: 언어 교정
        let correctionRow = makeSettingRow(label: "언어 교정", control: languageCorrectionSwitch)

        // Row 3: 인식 언어
        let languageRow = makeSettingRow(label: "인식 언어", control: languageButton)

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        [accuracyRow, divider1, correctionRow, divider2, languageRow].forEach {
            settingsStack.addArrangedSubview($0)
        }

        accuracyRow.snp.makeConstraints { $0.height.equalTo(52) }
        correctionRow.snp.makeConstraints { $0.height.equalTo(52) }
        languageRow.snp.makeConstraints { $0.height.equalTo(52) }

        // Action Button
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(52)
        }
    }

    private func makeSettingRow(label: String, control: UIView) -> UIStackView {
        let lbl = UILabel()
        lbl.text = label
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = AppColor.textPrimary

        let row = UIStackView(arrangedSubviews: [lbl, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = AppColor.border
        v.snp.makeConstraints { $0.height.equalTo(1) }
        return v
    }

    // MARK: - OCR

    private func updateRequestSettings() {
        imageOCR.request.usesLanguageCorrection = languageCorrection
        imageOCR.request.recognitionLanguages = [selectedLanguage]
        imageOCR.request.recognitionLevel = selectedRecognitionLevel == "Fast" ? .fast : .accurate
    }

    private func runOCR() {
        updateRequestSettings()
        Task {
            do {
                try await imageOCR.performOCR(imageData: imageData)
                await MainActor.run {
                    drawBoundingBoxes()
                }
            } catch {
                print("OCR error: \(error)")
            }
        }
    }

    private func drawBoundingBoxes() {
        boxOverlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        guard let image = photoImageView.image else { return }

        let renderedRect = imageRenderedRect(imageSize: image.size, in: boxOverlayView.bounds.size)

        for observation in imageOCR.observations {
            let imageCoords = observation.boundingBox.toImageCoordinates(renderedRect.size, origin: .upperLeft)
            let boxRect = CGRect(
                x: renderedRect.origin.x + imageCoords.origin.x,
                y: renderedRect.origin.y + imageCoords.origin.y,
                width: imageCoords.width,
                height: imageCoords.height
            )

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(roundedRect: boxRect, cornerRadius: 4).cgPath
            shapeLayer.strokeColor = AppColor.accent.cgColor
            shapeLayer.fillColor = AppColor.accent.withAlphaComponent(0.13).cgColor
            shapeLayer.lineWidth = 1.5
            boxOverlayView.layer.addSublayer(shapeLayer)
        }
    }

    private func imageRenderedRect(imageSize: CGSize, in viewSize: CGSize) -> CGRect {
        guard viewSize.width > 0, viewSize.height > 0 else { return .zero }
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        if imageAspect > viewAspect {
            let scale = viewSize.width / imageSize.width
            let scaledHeight = imageSize.height * scale
            return CGRect(x: 0, y: (viewSize.height - scaledHeight) / 2, width: viewSize.width, height: scaledHeight)
        } else {
            let scale = viewSize.height / imageSize.height
            let scaledWidth = imageSize.width * scale
            return CGRect(x: (viewSize.width - scaledWidth) / 2, y: 0, width: scaledWidth, height: viewSize.height)
        }
    }

    // MARK: - Language Picker

    private func updateLanguageButtonTitle() {
        let identifier = selectedLanguage.maximalIdentifier
        let displayName = Locale.current.localizedString(forLanguageCode: identifier) ?? identifier
        languageButton.setTitle("\(identifier)-\(displayName)", for: .normal)
    }

    private func showLanguagePicker() {
        let alert = UIAlertController(title: "인식 언어", message: nil, preferredStyle: .actionSheet)
        for lang in supportedLanguages {
            let id = lang.maximalIdentifier
            let displayName = Locale.current.localizedString(forLanguageCode: id) ?? id
            let action = UIAlertAction(title: "\(id)-\(displayName)", style: .default) { [weak self] _ in
                self?.selectedLanguage = lang
                self?.updateLanguageButtonTitle()
                self?.runOCR()
            }
            if lang.maximalIdentifier == selectedLanguage.maximalIdentifier {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions

    private func bindActions() {
        accuracySegmentedControl.rx.selectedSegmentIndex
            .skip(1)
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                self.selectedRecognitionLevel = self.recognitionLevels[index]
                self.runOCR()
            })
            .disposed(by: disposeBag)

        languageCorrectionSwitch.rx.isOn
            .skip(1)
            .subscribe(onNext: { [weak self] isOn in
                self?.languageCorrection = isOn
                self?.runOCR()
            })
            .disposed(by: disposeBag)

        languageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showLanguagePicker()
            })
            .disposed(by: disposeBag)

        actionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                // Y 내림차순 정렬 (Vision 좌표계: 아래가 0) → 위에서 아래 순서
                let sortedObservations = self.imageOCR.observations.sorted {
                    $0.boundingBox.origin.y > $1.boundingBox.origin.y
                }
                let lines = sortedObservations
                    .compactMap { $0.topCandidates(1).first }
                    .filter { $0.confidence > 0.3 && $0.string.count >= 2 }
                    .flatMap { candidate in
                        candidate.string.components(separatedBy: .newlines)
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty && $0.count >= 2 }
                    }
                guard !lines.isEmpty else { return }
                let vc = SentenceSelectionViewController(sentences: lines, book: self.book)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
