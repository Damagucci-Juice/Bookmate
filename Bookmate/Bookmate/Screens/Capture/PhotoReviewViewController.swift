import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhotoReviewViewController: UIViewController {

    // MARK: - Properties

    private var imageData: Data?
    private let book: Book
    private let disposeBag = DisposeBag()

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

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(photoImageView)
        view.addSubview(buttonBar)

        let buttonStack = UIStackView(arrangedSubviews: [retakeButton, recognizeButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonBar.addSubview(buttonStack)

        photoImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonBar.snp.top)
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
    }

    // MARK: - Actions

    private func bindActions() {
        retakeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        recognizeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self, let data = self.imageData else { return }
                let vc = TextRecognitionViewController(imageData: data, book: self.book)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
