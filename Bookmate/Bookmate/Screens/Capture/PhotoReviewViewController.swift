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
    }

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isAdjustMode, let image = photoImageView.image {
            regionOverlay.imageRenderedRect = imageRenderedRect(imageSize: image.size, in: photoImageView.bounds.size)
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

            regionOverlay.isHidden = false
            photoImageView.isUserInteractionEnabled = true
            if let image = photoImageView.image {
                let rendered = imageRenderedRect(imageSize: image.size, in: photoImageView.bounds.size)
                regionOverlay.configure(normalizedRegion: regionOfInterest, imageRenderedRect: rendered)
            }
        } else {
            adjustButton.setTitle("영역 조절", for: .normal)
            adjustButton.backgroundColor = .clear
            adjustButton.layer.borderWidth = 1.5

            regionOverlay.isHidden = true
            photoImageView.isUserInteractionEnabled = false
        }
    }

    // MARK: - Image Crop

    /// 영역 조절을 했으면 해당 영역만 크롭한 JPEG Data 반환, 조절 안 했으면 nil
    private func croppedImageData(from data: Data) -> Data? {
        let fullRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        guard regionOfInterest != fullRect else { return nil }

        guard let image = UIImage(data: data), let cgImage = image.cgImage else { return nil }

        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)

        // Vision 정규 좌표 (좌하단 원점) → CGImage 픽셀 좌표 (좌상단 원점)
        let pixelRect = CGRect(
            x: regionOfInterest.origin.x * w,
            y: (1.0 - regionOfInterest.origin.y - regionOfInterest.height) * h,
            width: regionOfInterest.width * w,
            height: regionOfInterest.height * h
        ).integral

        guard let cropped = cgImage.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
            .jpegData(compressionQuality: 0.95)
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
