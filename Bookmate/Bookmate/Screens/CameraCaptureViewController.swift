import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation

final class CameraCaptureViewController: UIViewController {

    // MARK: - Properties

    private let book: Book
    private let disposeBag = DisposeBag()

    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Init

    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.close.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    private let bookInfoBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#1A1A1A")
        return v
    }()

    private let bookIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        iv.image = UIImage(systemName: AppIcon.bookOpen.sfSymbolName, withConfiguration: config)
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let bookLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.5)
        return l
    }()

    private let viewfinderView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = true
        return v
    }()

    private let hintLabel: UILabel = {
        let l = UILabel()
        l.text = "책 페이지에 카메라를 맞춰주세요"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.textAlignment = .center
        return l
    }()

    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    private let galleryButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "photo", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(hex: "#333333")
        btn.layer.cornerRadius = 22
        return btn
    }()

    private let shutterButton: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()

    private let textModeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("T", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(hex: "#333333")
        btn.layer.cornerRadius = 22
        return btn
    }()

    // Corner guide layers
    private let cornerTL = CAShapeLayer()
    private let cornerTR = CAShapeLayer()
    private let cornerBL = CAShapeLayer()
    private let cornerBR = CAShapeLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        configureBookInfo()
        bindActions()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = viewfinderView.bounds
        drawCornerGuides()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Layout

    private func setupLayout() {
        // Header
        let headerView = UIView()
        view.addSubview(headerView)
        headerView.addSubview(closeButton)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        // Book Info Bar
        view.addSubview(bookInfoBar)
        bookInfoBar.addSubview(bookIcon)
        bookInfoBar.addSubview(bookLabel)

        bookInfoBar.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        bookIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }
        bookLabel.snp.makeConstraints {
            $0.leading.equalTo(bookIcon.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        // Viewfinder
        view.addSubview(viewfinderView)
        viewfinderView.addSubview(hintLabel)

        viewfinderView.snp.makeConstraints {
            $0.top.equalTo(bookInfoBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        hintLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }

        // Bottom Controls
        view.addSubview(bottomBar)
        bottomBar.addSubview(galleryButton)
        bottomBar.addSubview(shutterButton)
        bottomBar.addSubview(textModeButton)

        bottomBar.snp.makeConstraints {
            $0.top.equalTo(viewfinderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(120)
        }

        galleryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.top.equalToSuperview().offset(20)
            $0.size.equalTo(44)
        }

        shutterButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.size.equalTo(68)
        }

        textModeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-40)
            $0.top.equalToSuperview().offset(20)
            $0.size.equalTo(44)
        }

        setupShutterButton()

        // Add corner guide layers to viewfinder
        [cornerTL, cornerTR, cornerBL, cornerBR].forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = AppColor.accent.cgColor
            $0.lineWidth = 2.5
            $0.lineCap = .round
            viewfinderView.layer.addSublayer($0)
        }
    }

    private func setupShutterButton() {
        // Outer ring
        let outerRing = UIView()
        outerRing.backgroundColor = .clear
        outerRing.layer.borderWidth = 3
        outerRing.layer.borderColor = UIColor.white.cgColor
        outerRing.layer.cornerRadius = 34
        outerRing.isUserInteractionEnabled = false
        shutterButton.addSubview(outerRing)
        outerRing.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Inner circle
        let innerCircle = UIView()
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 27
        innerCircle.isUserInteractionEnabled = false
        shutterButton.addSubview(innerCircle)
        innerCircle.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(54)
        }
    }

    private func drawCornerGuides() {
        let inset: CGFloat = 35
        let cornerLen: CGFloat = 24
        let bounds = viewfinderView.bounds
        let top: CGFloat = 60
        let bottom = bounds.height - 60

        // Top-left
        let tlPath = UIBezierPath()
        tlPath.move(to: CGPoint(x: inset, y: top + cornerLen))
        tlPath.addLine(to: CGPoint(x: inset, y: top))
        tlPath.addLine(to: CGPoint(x: inset + cornerLen, y: top))
        cornerTL.path = tlPath.cgPath

        // Top-right
        let trPath = UIBezierPath()
        trPath.move(to: CGPoint(x: bounds.width - inset - cornerLen, y: top))
        trPath.addLine(to: CGPoint(x: bounds.width - inset, y: top))
        trPath.addLine(to: CGPoint(x: bounds.width - inset, y: top + cornerLen))
        cornerTR.path = trPath.cgPath

        // Bottom-left
        let blPath = UIBezierPath()
        blPath.move(to: CGPoint(x: inset, y: bottom - cornerLen))
        blPath.addLine(to: CGPoint(x: inset, y: bottom))
        blPath.addLine(to: CGPoint(x: inset + cornerLen, y: bottom))
        cornerBL.path = blPath.cgPath

        // Bottom-right
        let brPath = UIBezierPath()
        brPath.move(to: CGPoint(x: bounds.width - inset - cornerLen, y: bottom))
        brPath.addLine(to: CGPoint(x: bounds.width - inset, y: bottom))
        brPath.addLine(to: CGPoint(x: bounds.width - inset, y: bottom - cornerLen))
        cornerBR.path = brPath.cgPath
    }

    // MARK: - Configure

    private func configureBookInfo() {
        var parts: [String] = []
        if !book.title.isEmpty { parts.append(book.title) }
        if !book.author.isEmpty { parts.append(book.author) }
        bookLabel.text = parts.joined(separator: " · ")
    }

    // MARK: - Camera

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        viewfinderView.layer.insertSublayer(layer, at: 0)
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // MARK: - Actions

    private func bindActions() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        shutterButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.capturePhoto()
            })
            .disposed(by: disposeBag)

        galleryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.openGallery()
            })
            .disposed(by: disposeBag)
    }

    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func handleCapturedImage(data: Data) {
        // TODO: Navigate to PhotoReviewViewController (3-2 사진 확인)
        // For now, print confirmation that photo was captured
        print("Photo captured: \(data.count) bytes for book: \(book.title)")
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else { return }
        handleCapturedImage(data: data)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CameraCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.9) {
            handleCapturedImage(data: data)
        }
    }
}
