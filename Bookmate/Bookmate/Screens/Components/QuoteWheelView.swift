import UIKit
import SnapKit

// MARK: - Data Model

struct WheelQuoteItem {
    let text: String
    let bookTitle: String
    let author: String
    let page: Int?
    let backgroundColor: UIColor
    let textColor: UIColor
}

// MARK: - QuoteWheelView

final class QuoteWheelView: UIView {

    // MARK: - Properties

    private var items: [WheelQuoteItem] = []
    private var scrollOffset: CGFloat = 0
    private var maxCardHeight: CGFloat = 200

    var onQuoteTapped: ((Int) -> Void)?

    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 200
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.require(toFail: pan)
        container.addGestureRecognizer(tap)
    }

    // MARK: - Public

    /// 현재 보이는 카드의 data index
    var currentIndex: Int {
        get {
            guard !items.isEmpty else { return 0 }
            let count = items.count
            let slot = Int(scrollOffset.rounded())
            return ((slot % count) + count) % count
        }
        set {
            guard !items.isEmpty else { return }
            scrollOffset = CGFloat(newValue)
            layoutVisibleCards()
        }
    }

    func configure(with items: [WheelQuoteItem]) {
        self.items = items
        self.scrollOffset = 0
        self.maxCardHeight = computeMaxHeight(items: items)
        rebuildCards()
    }

    private func computeMaxHeight(items: [WheelQuoteItem]) -> CGFloat {
        let measuringCard = WheelCardView()
        measuringCard.setExpanded(true)
        var tallest: CGFloat = cardHeight
        for item in items {
            measuringCard.configureContent(item: item)
            let h = measuringCard.preferredHeight(forWidth: cardWidth)
            if h > tallest { tallest = h }
        }
        return tallest
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
        let centerY = containerH - maxCardHeight / 2
        let cardX = (containerW - cardWidth) / 2
        let count = items.count

        let centerSlot = Int(scrollOffset.rounded())
        // Dynamically compute how many stacked cards fit above the front card
        let availableAbove = containerH - maxCardHeight
        let visibleSlots = max(0, min(count - 1, Int(availableAbove / rowHeight)))
        let slotRange = (centerSlot - visibleSlots)...(centerSlot + 1)

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
            let isFront = (slot == centerSlot)

            // Get or create card
            let card: WheelCardView
            if let existing = activeCards[slot] {
                card = existing
            } else {
                card = dequeueCard()
                card.configureContent(item: items[dataIndex])
                activeCards[slot] = card
            }

            card.setExpanded(isFront)

            let h: CGFloat
            let yPos: CGFloat

            if isFront {
                h = maxCardHeight
                yPos = containerH - h  // bottom-anchored
            } else if slot > centerSlot {
                // Buffer card: hide below container (clipped by clipsToBounds)
                h = maxCardHeight
                yPos = containerH
            } else {
                h = maxCardHeight
                yPos = centerY - maxCardHeight / 2 + visualOffset * rowHeight
            }

            card.frame = CGRect(x: cardX, y: yPos, width: cardWidth, height: h)
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

    private var panStartOffset: CGFloat = 0

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !items.isEmpty else { return }

        switch gesture.state {
        case .began:
            panStartOffset = scrollOffset

        case .changed:
            guard items.count > 1 else { return }
            let translation = gesture.translation(in: container)
            let rawDelta = -translation.y / rowHeight
            // Clamp dragging to at most 1 card in either direction
            let clampedDelta = max(-1, min(1, rawDelta))
            scrollOffset = panStartOffset + clampedDelta
            layoutVisibleCards()

        case .ended, .cancelled:
            let snapTarget = scrollOffset.rounded()

            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                self.scrollOffset = snapTarget
                self.layoutVisibleCards()
            }

        default:
            break
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !items.isEmpty else { return }
        let centerSlot = Int(scrollOffset.rounded())
        guard let frontCard = activeCards[centerSlot] else { return }
        let location = gesture.location(in: container)
        guard frontCard.frame.contains(location) else { return }
        let count = items.count
        let dataIndex = ((centerSlot % count) + count) % count
        onQuoteTapped?(dataIndex)
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

    private let bookTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let authorPageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
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
        bookTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        authorPageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        authorPageLabel.setContentHuggingPriority(.required, for: .horizontal)
        infoStack.addArrangedSubview(bookTitleLabel)
        infoStack.addArrangedSubview(authorPageLabel)
        stack.addArrangedSubview(quoteLabel)
        stack.addArrangedSubview(infoStack)
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func setExpanded(_ expanded: Bool) {
        quoteLabel.numberOfLines = 0
    }

    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        let insetWidth = width - 24 * 2  // leading + trailing insets
        let fittingSize = CGSize(width: insetWidth, height: .greatestFiniteMagnitude)
        let size = stack.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size.height + 20 + 20  // top + bottom insets
    }

    func configureContent(item: WheelQuoteItem) {
        backgroundColor = item.backgroundColor

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        quoteLabel.attributedText = NSAttributedString(
            string: item.text,
            attributes: [
                .font: AppFont.quoteText.font,
                .foregroundColor: item.textColor,
                .paragraphStyle: paragraphStyle,
                .kern: -0.2
            ]
        )

        // Book title (left side, truncates if needed)
        if item.bookTitle.isEmpty {
            bookTitleLabel.isHidden = true
        } else {
            bookTitleLabel.isHidden = false
            bookTitleLabel.text = item.bookTitle
            bookTitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
            bookTitleLabel.textColor = AppColor.textSecondary
        }

        // Author · page (right side, never truncates)
        var parts: [String] = []
        if !item.author.isEmpty { parts.append(item.author) }
        if let page = item.page { parts.append("p.\(page)") }

        if parts.isEmpty {
            authorPageLabel.isHidden = true
        } else {
            authorPageLabel.isHidden = false
            let separator = item.bookTitle.isEmpty ? "" : " · "
            authorPageLabel.text = separator + parts.joined(separator: " · ")
            authorPageLabel.font = .systemFont(ofSize: 11, weight: .regular)
            authorPageLabel.textColor = AppColor.textSecondary
        }
    }
}
