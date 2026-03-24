import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhotoReviewViewController: UIViewController {

    // MARK: - Properties

    private var imageData: Data?
    private let book: Book
    private let disposeBag = DisposeBag()

    private var isAdjustMode = false
    private var regionOfInterest: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    private let fullRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    private var isCropped: Bool { regionOfInterest != fullRect }

    // Crop Preview Layers (조절 모드 아닐 때 표시)
    private let cropDimmingLayer = CAShapeLayer()
    private let cropBorderLayer = CAShapeLayer()

    // MARK: - Init

    init(imageData: Data, book: Book) {
        self.imageData = imageData
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        return iv
    }()

    private lazy var regionOverlay: RegionAdjustOverlayView = {
        let v = RegionAdjustOverlayView()
        v.isHidden = true
        v.onRegionChanged = { [weak self] region in
            self?.regionOfInterest = region
        }
        return v
    }()

    private let buttonBar: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    private let retakeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("다시 촬영", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.white.cgColor
        return btn
    }()

    private let adjustButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("영역 조절", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.white.cgColor
        return btn
    }()

    private let recognizeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("계속하기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColor.accent
        btn.layer.cornerRadius = 14
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        bindActions()
        if let data = imageData {
            photoImageView.image = UIImage(data: data)
        }
        setupCropPreviewLayers()
    }

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let image = photoImageView.image {
            let rendered = imageRenderedRect(imageSize: image.size, in: photoImageView.bounds.size)
            if isAdjustMode {
                regionOverlay.imageRenderedRect = rendered
            }
            updateCropPreview(rendered: rendered)
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(photoImageView)
        photoImageView.addSubview(regionOverlay)
        view.addSubview(buttonBar)

        let topRow = UIStackView(arrangedSubviews: [retakeButton, adjustButton])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.distribution = .fillEqually

        let buttonStack = UIStackView(arrangedSubviews: [topRow, recognizeButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonBar.addSubview(buttonStack)

        photoImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonBar.snp.top)
        }

        regionOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        buttonBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        retakeButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        recognizeButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }

    // MARK: - Actions

    private func bindActions() {
        retakeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        adjustButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.toggleAdjustMode()
            })
            .disposed(by: disposeBag)

        recognizeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self, let data = self.imageData else { return }
                let finalData = self.croppedImageData(from: data) ?? data
                let vc = TextRecognitionViewController(imageData: finalData, book: self.book)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func toggleAdjustMode() {
        isAdjustMode.toggle()

        if isAdjustMode {
            adjustButton.setTitle("완료", for: .normal)
            adjustButton.backgroundColor = AppColor.accent
            adjustButton.layer.borderWidth = 0

            setCropPreviewVisible(false)
            regionOverlay.isHidden = false
            photoImageView.isUserInteractionEnabled = true
            if let image = photoImageView.image {
                let rendered = imageRenderedRect(imageSize: image.size, in: photoImageView.bounds.size)
                regionOverlay.configure(normalizedRegion: regionOfInterest, imageRenderedRect: rendered)
            }
        } else {
            regionOverlay.isHidden = true
            photoImageView.isUserInteractionEnabled = false
            updateAdjustButtonAppearance()
            setCropPreviewVisible(isCropped)
        }
    }

    private func updateAdjustButtonAppearance() {
        if isCropped {
            adjustButton.setTitle("영역 재조절", for: .normal)
            adjustButton.backgroundColor = AppColor.accent.withAlphaComponent(0.3)
            adjustButton.layer.borderWidth = 1.5
            adjustButton.layer.borderColor = AppColor.accent.cgColor
        } else {
            adjustButton.setTitle("영역 조절", for: .normal)
            adjustButton.backgroundColor = .clear
            adjustButton.layer.borderWidth = 1.5
            adjustButton.layer.borderColor = UIColor.white.cgColor
        }
    }

    // MARK: - Crop Preview

    private func setupCropPreviewLayers() {
        cropDimmingLayer.fillRule = .evenOdd
        cropDimmingLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        cropDimmingLayer.isHidden = true

        cropBorderLayer.strokeColor = AppColor.accent.cgColor
        cropBorderLayer.fillColor = UIColor.clear.cgColor
        cropBorderLayer.lineWidth = 2
        cropBorderLayer.lineDashPattern = [8, 4]
        cropBorderLayer.isHidden = true

        photoImageView.layer.addSublayer(cropDimmingLayer)
        photoImageView.layer.addSublayer(cropBorderLayer)
    }

    private func setCropPreviewVisible(_ visible: Bool) {
        cropDimmingLayer.isHidden = !visible
        cropBorderLayer.isHidden = !visible
    }

    private func updateCropPreview(rendered: CGRect) {
        guard !isAdjustMode, isCropped else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let bounds = photoImageView.bounds

        // Vision 정규 좌표 → 뷰 좌표
        let cropRect = CGRect(
            x: rendered.origin.x + regionOfInterest.origin.x * rendered.width,
            y: rendered.origin.y + (1.0 - regionOfInterest.origin.y - regionOfInterest.height) * rendered.height,
            width: regionOfInterest.width * rendered.width,
            height: regionOfInterest.height * rendered.height
        )

        // Dimming (선택 영역 외부)
        let outerPath = UIBezierPath(rect: bounds)
        outerPath.append(UIBezierPath(rect: cropRect))
        cropDimmingLayer.path = outerPath.cgPath
        cropDimmingLayer.frame = bounds

        // Border
        cropBorderLayer.path = UIBezierPath(rect: cropRect).cgPath
        cropBorderLayer.frame = bounds

        CATransaction.commit()
    }

    // MARK: - Image Crop

    /// 영역 조절을 했으면 해당 영역만 크롭한 JPEG Data 반환, 조절 안 했으면 nil
    private func croppedImageData(from data: Data) -> Data? {
        guard isCropped else { return nil }
        guard let original = UIImage(data: data) else { return nil }

        // orientation을 적용한 이미지로 변환 (raw CGImage 좌표 ≠ 표시 좌표 문제 해결)
        let renderer = UIGraphicsImageRenderer(size: original.size)
        let normalized = renderer.image { _ in original.draw(at: .zero) }
        guard let cgImage = normalized.cgImage else { return nil }

        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)

        // 정규 좌표 (좌하단 원점) → 픽셀 좌표 (좌상단 원점)
        let pixelRect = CGRect(
            x: regionOfInterest.origin.x * w,
            y: (1.0 - regionOfInterest.origin.y - regionOfInterest.height) * h,
            width: regionOfInterest.width * w,
            height: regionOfInterest.height * h
        ).integral

        guard let cropped = cgImage.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped).jpegData(compressionQuality: 0.95)
    }

    // MARK: - Helpers

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
}
