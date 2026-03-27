import UIKit
import SnapKit

// MARK: - Data Model

struct WheelQuoteItem {
    let text: String
    let source: String
    let backgroundColor: UIColor
    let textColor: UIColor
}

// MARK: - QuoteWheelView

final class QuoteWheelView: UIView {

    // MARK: - Properties

    private var items: [WheelQuoteItem] = []
    private var scrollOffset: CGFloat = 0

    private let maxVisibleSlots = 5
    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 150
    private let rowHeight: CGFloat = 70

    private let container = UIView()
    private var cardPool: [WheelCardView] = []
    private var activeCards: [Int: WheelCardView] = [:]  // key = slot (continuous integer)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainer()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupContainer() {
        container.clipsToBounds = true
        addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        container.addGestureRecognizer(pan)
    }

    // MARK: - Public

    func configure(with items: [WheelQuoteItem]) {
        self.items = items
        self.scrollOffset = 0
        rebuildCards()
    }

    // MARK: - Card Pool

    private func dequeueCard() -> WheelCardView {
        if let card = cardPool.popLast() {
            card.isHidden = false
            return card
        }
        let card = WheelCardView()
        container.addSubview(card)
        return card
    }

    private func recycleCard(_ card: WheelCardView) {
        card.isHidden = true
        cardPool.append(card)
    }

    // MARK: - Layout

    private func rebuildCards() {
        for (_, card) in activeCards {
            recycleCard(card)
        }
        activeCards.removeAll()
        layoutVisibleCards()
    }

    private func layoutVisibleCards() {
        guard !items.isEmpty else { return }

        let containerH = bounds.height
        let containerW = bounds.width
        guard containerH > 0, containerW > 0 else { return }

        // Anchor at bottom: current card (offset 0) sits fully visible at container bottom
        let centerY = containerH - cardHeight / 2
        let cardX = (containerW - cardWidth) / 2
        let count = items.count

        let centerSlot = Int(scrollOffset.rounded())
        // Render cards above current + 1 buffer below for swipe animation
        let slotRange = (centerSlot - maxVisibleSlots)...(centerSlot + 1)

        // Recycle cards outside visible range
        let neededSlots = Set(slotRange)
        let toRemove = activeCards.keys.filter { !neededSlots.contains($0) }
        for slot in toRemove {
            if let card = activeCards.removeValue(forKey: slot) {
                recycleCard(card)
            }
        }

        var cardsByY: [(yPos: CGFloat, slot: Int, card: WheelCardView)] = []

        for slot in slotRange {
            let dataIndex = ((slot % count) + count) % count
            let visualOffset = CGFloat(slot) - scrollOffset

            // Get or create card
            let card: WheelCardView
            if let existing = activeCards[slot] {
                card = existing
            } else {
                card = dequeueCard()
                card.configureContent(item: items[dataIndex])
                activeCards[slot] = card
            }

            let yPos = centerY - cardHeight / 2 + visualOffset * rowHeight
            card.frame = CGRect(x: cardX, y: yPos, width: cardWidth, height: cardHeight)
            card.layer.cornerRadius = 16

            cardsByY.append((yPos: yPos, slot: slot, card: card))
        }

        // Z-order: bottom cards on top, but +1 buffer always at back
        cardsByY.sort { a, b in
            let aIsBuffer = a.slot > centerSlot
            let bIsBuffer = b.slot > centerSlot
            if aIsBuffer != bIsBuffer { return aIsBuffer }  // buffer goes to back
            return a.yPos < b.yPos  // among visible: bottom on top
        }
        for entry in cardsByY {
            container.bringSubviewToFront(entry.card)
        }
    }

    // MARK: - Pan Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !items.isEmpty else { return }

        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: container)
            gesture.setTranslation(.zero, in: container)
            scrollOffset += -translation.y / rowHeight
            layoutVisibleCards()

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: container).y
            let velocityCards = -velocity / rowHeight

            let snapTarget = (scrollOffset + velocityCards * 0.15).rounded()

            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: abs(velocityCards) * 0.05,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                self.scrollOffset = snapTarget
                self.layoutVisibleCards()
            }

        default:
            break
        }
    }

    // MARK: - Layout Cycle

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutVisibleCards()
    }
}

// MARK: - WheelCardView

final class WheelCardView: UIView {

    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        stack.addArrangedSubview(quoteLabel)
        stack.addArrangedSubview(sourceLabel)
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configureContent(item: WheelQuoteItem) {
        backgroundColor = item.backgroundColor

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        quoteLabel.attributedText = NSAttributedString(
            string: item.text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                .foregroundColor: item.textColor,
                .paragraphStyle: paragraphStyle,
                .kern: -0.2
            ]
        )

        if item.source.isEmpty {
            sourceLabel.isHidden = true
        } else {
            sourceLabel.isHidden = false
            sourceLabel.text = item.source
            sourceLabel.font = .systemFont(ofSize: 11, weight: .regular)
            sourceLabel.textColor = AppColor.textSecondary
        }
    }
}
