import UIKit

final class RegionAdjustOverlayView: UIView {

    // MARK: - Public

    /// Vision 정규 좌표 (0-1, 좌하단 원점)
    private(set) var normalizedRegion: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    /// 이미지가 실제 렌더링되는 영역 (scaleAspectFit 기준)
    var imageRenderedRect: CGRect = .zero {
        didSet { updateLayout() }
    }

    var onRegionChanged: ((CGRect) -> Void)?

    func configure(normalizedRegion: CGRect, imageRenderedRect: CGRect) {
        self.normalizedRegion = normalizedRegion
        self.imageRenderedRect = imageRenderedRect
    }

    // MARK: - Constants

    private let handleSize: CGFloat = 28
    private let handleHitArea: CGFloat = 44
    private let minimumRegionSize: CGFloat = 40
    private let handleBorderWidth: CGFloat = 2.5

    // MARK: - Layers

    private let dimmingLayer = CAShapeLayer()
    private let regionBorderLayer = CAShapeLayer()

    // MARK: - Handles (topLeft, topRight, bottomLeft, bottomRight)

    private var handles: [UIView] = []

    private enum Corner: Int {
        case topLeft = 0, topRight, bottomRight, bottomLeft
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        clipsToBounds = true
        isUserInteractionEnabled = true

        // Dimming
        dimmingLayer.fillRule = .evenOdd
        dimmingLayer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.addSublayer(dimmingLayer)

        // Region border
        regionBorderLayer.strokeColor = AppColor.accent.cgColor
        regionBorderLayer.fillColor = UIColor.clear.cgColor
        regionBorderLayer.lineWidth = 2
        regionBorderLayer.lineDashPattern = [6, 4]
        layer.addSublayer(regionBorderLayer)

        // 4 corner handles
        for i in 0..<4 {
            let handle = UIView()
            handle.backgroundColor = .white
            handle.layer.cornerRadius = handleSize / 2
            handle.layer.borderWidth = handleBorderWidth
            handle.layer.borderColor = AppColor.accent.cgColor
            handle.layer.shadowColor = UIColor.black.cgColor
            handle.layer.shadowOpacity = 0.15
            handle.layer.shadowOffset = CGSize(width: 0, height: 1)
            handle.layer.shadowRadius = 3
            handle.tag = i
            addSubview(handle)

            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            handle.addGestureRecognizer(pan)
            handle.isUserInteractionEnabled = true

            handles.append(handle)
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let regionViewRect = regionRectInView()
        positionHandles(for: regionViewRect)
        updateDimming(for: regionViewRect)
        updateBorder(for: regionViewRect)

        CATransaction.commit()
    }

    // MARK: - Coordinate Conversion

    /// Vision 정규 좌표 → 뷰 좌표
    private func viewPoint(from normalized: CGPoint) -> CGPoint {
        let r = imageRenderedRect
        let x = r.origin.x + normalized.x * r.width
        let y = r.origin.y + (1.0 - normalized.y) * r.height  // Y 뒤집기
        return CGPoint(x: x, y: y)
    }

    /// 뷰 좌표 → Vision 정규 좌표
    private func normalizedPoint(from viewPt: CGPoint) -> CGPoint {
        let r = imageRenderedRect
        guard r.width > 0, r.height > 0 else { return .zero }
        let nx = (viewPt.x - r.origin.x) / r.width
        let ny = 1.0 - ((viewPt.y - r.origin.y) / r.height)
        return CGPoint(x: clamp(nx, 0, 1), y: clamp(ny, 0, 1))
    }

    private func regionRectInView() -> CGRect {
        let origin = viewPoint(from: CGPoint(x: normalizedRegion.minX, y: normalizedRegion.maxY))
        let end = viewPoint(from: CGPoint(x: normalizedRegion.maxX, y: normalizedRegion.minY))
        return CGRect(x: origin.x, y: origin.y, width: end.x - origin.x, height: end.y - origin.y)
    }

    // MARK: - Drawing

    private func positionHandles(for rect: CGRect) {
        let corners = [
            CGPoint(x: rect.minX, y: rect.minY),  // topLeft
            CGPoint(x: rect.maxX, y: rect.minY),  // topRight
            CGPoint(x: rect.maxX, y: rect.maxY),  // bottomRight
            CGPoint(x: rect.minX, y: rect.maxY),  // bottomLeft
        ]
        let half = handleSize / 2
        for (i, center) in corners.enumerated() {
            handles[i].frame = CGRect(x: center.x - half, y: center.y - half, width: handleSize, height: handleSize)
        }
    }

    private func updateDimming(for rect: CGRect) {
        let outerPath = UIBezierPath(rect: bounds)
        let innerPath = UIBezierPath(roundedRect: rect, cornerRadius: 2)
        outerPath.append(innerPath)
        dimmingLayer.path = outerPath.cgPath
        dimmingLayer.frame = bounds
    }

    private func updateBorder(for rect: CGRect) {
        regionBorderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 2).cgPath
        regionBorderLayer.frame = bounds
    }

    // MARK: - Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let handle = gesture.view, let corner = Corner(rawValue: handle.tag) else { return }

        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)

        let center = CGPoint(x: handle.center.x + translation.x, y: handle.center.y + translation.y)
        let clamped = clampToImageRect(center)

        // 현재 영역의 뷰 좌표 구하기
        var rect = regionRectInView()

        switch corner {
        case .topLeft:
            let newX = min(clamped.x, rect.maxX - minimumRegionSize)
            let newY = min(clamped.y, rect.maxY - minimumRegionSize)
            rect = CGRect(x: newX, y: newY, width: rect.maxX - newX, height: rect.maxY - newY)
        case .topRight:
            let newMaxX = max(clamped.x, rect.minX + minimumRegionSize)
            let newY = min(clamped.y, rect.maxY - minimumRegionSize)
            rect = CGRect(x: rect.minX, y: newY, width: newMaxX - rect.minX, height: rect.maxY - newY)
        case .bottomRight:
            let newMaxX = max(clamped.x, rect.minX + minimumRegionSize)
            let newMaxY = max(clamped.y, rect.minY + minimumRegionSize)
            rect = CGRect(x: rect.minX, y: rect.minY, width: newMaxX - rect.minX, height: newMaxY - rect.minY)
        case .bottomLeft:
            let newX = min(clamped.x, rect.maxX - minimumRegionSize)
            let newMaxY = max(clamped.y, rect.minY + minimumRegionSize)
            rect = CGRect(x: newX, y: rect.minY, width: rect.maxX - newX, height: newMaxY - rect.minY)
        }

        // 뷰 좌표 → 정규 좌표로 변환
        let topLeftNorm = normalizedPoint(from: CGPoint(x: rect.minX, y: rect.minY))
        let bottomRightNorm = normalizedPoint(from: CGPoint(x: rect.maxX, y: rect.maxY))
        normalizedRegion = CGRect(
            x: topLeftNorm.x,
            y: bottomRightNorm.y,
            width: bottomRightNorm.x - topLeftNorm.x,
            height: topLeftNorm.y - bottomRightNorm.y
        )

        updateLayout()

        if gesture.state == .ended || gesture.state == .cancelled {
            onRegionChanged?(normalizedRegion)
        }
    }

    // MARK: - Helpers

    private func clampToImageRect(_ point: CGPoint) -> CGPoint {
        let r = imageRenderedRect
        return CGPoint(
            x: clamp(point.x, r.minX, r.maxX),
            y: clamp(point.y, r.minY, r.maxY)
        )
    }

    private func clamp(_ value: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(value, lo), hi)
    }

    // MARK: - Hit Test (핸들 터치 영역 확대)

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for handle in handles {
            let expanded = handle.frame.insetBy(dx: -(handleHitArea - handleSize) / 2,
                                                 dy: -(handleHitArea - handleSize) / 2)
            if expanded.contains(point) {
                return handle
            }
        }
        return nil
    }
}
