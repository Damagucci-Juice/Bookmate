import SwiftUI
import RxSwift
import Combine

// MARK: - Data Model

struct QuoteCardItem: Identifiable {
    let id: Int
    let text: String
    let bookTitle: String
    let author: String
    let page: Int?
    let backgroundColor: Color
    let textColor: Color
}

// MARK: - ViewModel

class HomeViewModel: ObservableObject {
    @Published var quotes: [QuoteCardItem] = []
    @Published var isExpanded = false
    @Published var currentIndex = 0

    /// Raw Quote objects for UIKit navigation (CardCustomization needs the Realm object)
    private(set) var loadedQuotes: [Quote] = []

    var onQuoteTapped: ((Int) -> Void)?
    var onSeeAllTapped: (() -> Void)?
    var onEmptyCtaTapped: (() -> Void)?

    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()

    func loadQuotes() {
        quoteRepository.fetchAll()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] quotes in
                guard let self else { return }
                self.loadedQuotes = quotes
                let palette: [UIColor] = AppColor.WheelCard.palette
                self.quotes = quotes.enumerated().map { index, quote in
                    let bg = palette[index % palette.count]
                    let textColor = Self.textColorForBackground(bg)
                    return QuoteCardItem(
                        id: index,
                        text: quote.text,
                        bookTitle: quote.book?.title ?? "",
                        author: quote.book?.author ?? "",
                        page: quote.pageNumber,
                        backgroundColor: Color(bg),
                        textColor: Color(textColor)
                    )
                }
                if self.currentIndex >= self.quotes.count {
                    self.currentIndex = max(0, self.quotes.count - 1)
                }
            })
            .disposed(by: disposeBag)
    }

    private static func textColorForBackground(_ bg: UIColor) -> UIColor {
        if bg == AppColor.WheelCard.mutedGreen || bg == AppColor.WheelCard.dustyTeal {
            return .white
        }
        return AppColor.textPrimary
    }
}

// MARK: - HomeView

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            if viewModel.quotes.isEmpty {
                emptyStateView
            } else {
                curationHeader
                    .padding(.top, 12)
                cardArea
            }
            Spacer(minLength: 0)
        }
        .background(Color(AppColor.bg))
    }

    // MARK: - Header (네비게이션)

    private var headerSection: some View {
        HStack {
            Text("Bookmate")
                .font(.system(size: 26, weight: .bold))
                .tracking(-0.5)
                .foregroundColor(Color(AppColor.textPrimary))
            Spacer()
            if !viewModel.quotes.isEmpty {
                Button {
                    viewModel.onSeeAllTapped?()
                } label: {
                    Text("전체보기")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(AppColor.accent))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
    }

    // MARK: - Curation Header (큐레이션 + 토글)

    private var curationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("수집한 문장")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(AppColor.textPrimary))
                if viewModel.isExpanded {
                    Text("\(viewModel.quotes.count)개의 문장")
                        .font(.system(size: 13))
                        .foregroundColor(Color(AppColor.textSecondary))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    viewModel.isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d.down.left")
                        .font(.system(size: 14, weight: .medium))
                    Text(viewModel.isExpanded ? "접기" : "펼침")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color(AppColor.accent))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color(AppColor.card))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(AppColor.border), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Card Area

    private var cardArea: some View {
        Group {
            if viewModel.isExpanded {
                expandedCardList
            } else {
                stackedCardWheel
            }
        }
    }

    // MARK: - Stacked Card Wheel (접힘)

    private var stackedCardWheel: some View {
        GeometryReader { geo in
            let containerH = geo.size.height
            let containerW = geo.size.width - 40
            let cardW = min(containerW, 320.0)
            let maxCardH = min(containerH * 0.55, 280.0)
            let rowH: CGFloat = 70

            // How many stacked cards fit above the front card
            let availableAbove = containerH - maxCardH
            let maxVisible = max(0, Int(availableAbove / rowH))

            ZStack {
                ForEach(viewModel.quotes) { item in
                    // offset: 0 = front card, +1/+2/... = stacked above, -1 = buffer below
                    let offset = item.id - viewModel.currentIndex
                    let isVisible = offset >= -1 && offset <= maxVisible

                    if isVisible {
                        QuoteCardView(item: item, isExpanded: false)
                            .frame(width: cardW, height: maxCardH)
                            .offset(y: stackedY(
                                offset: offset,
                                containerH: containerH,
                                maxCardH: maxCardH,
                                rowH: rowH
                            ))
                            .opacity(stackedOpacity(offset: offset))
                            .zIndex(stackedZIndex(offset: offset, maxVisible: maxVisible))
                            .onTapGesture {
                                if offset == 0 {
                                    viewModel.onQuoteTapped?(item.id)
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                            if value.translation.height < -threshold {
                                viewModel.currentIndex = min(
                                    viewModel.currentIndex + 1,
                                    viewModel.quotes.count - 1
                                )
                            } else if value.translation.height > threshold {
                                viewModel.currentIndex = max(
                                    viewModel.currentIndex - 1,
                                    0
                                )
                            }
                        }
                    }
            )
        }
        .padding(.top, 16)
    }

    /// Front card at bottom, stacked cards above it
    private func stackedY(offset: Int, containerH: CGFloat, maxCardH: CGFloat, rowH: CGFloat) -> CGFloat {
        let frontY = (containerH - maxCardH) / 2
        if offset == 0 {
            return frontY
        } else if offset < 0 {
            // Previous card: hide below
            return containerH
        } else {
            // Next cards: stack upward
            return frontY - CGFloat(offset) * rowH
        }
    }

    private func stackedOpacity(offset: Int) -> Double {
        switch abs(offset) {
        case 0: return 1.0
        case 1: return 0.55
        case 2: return 0.28
        case 3: return 0.13
        default: return 0.06
        }
    }

    /// Front card on top (highest zIndex), stacked cards behind
    private func stackedZIndex(offset: Int, maxVisible: Int) -> Double {
        if offset < 0 { return -100 }
        return Double(maxVisible - offset + 1)
    }

    // MARK: - Expanded Card List (펼침)

    private var expandedCardList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.quotes) { item in
                    QuoteCardView(item: item, isExpanded: true)
                        .onTapGesture {
                            viewModel.onQuoteTapped?(item.id)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("home_empty_state")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .cornerRadius(20)

            VStack(spacing: 8) {
                Text("아직 수집한 문구가 없어요.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(AppColor.textPrimary))
                Text("첫 번째 문구를 채워볼까요?")
                    .font(.system(size: 15))
                    .foregroundColor(Color(AppColor.textSecondary))
            }

            Button {
                viewModel.onEmptyCtaTapped?()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("문구 수집 시작하기")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color(AppColor.accent))
                .cornerRadius(22)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - QuoteCardView

struct QuoteCardView: View {
    let item: QuoteCardItem
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.text)
                .font(Font(AppFont.quoteText.font))
                .lineLimit(isExpanded ? nil : 4)
                .lineSpacing(15 * 0.5)
                .tracking(-0.2)
                .foregroundColor(item.textColor)

            attributionRow
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var attributionRow: some View {
        let parts = attributionText
        if !parts.isEmpty {
            Text(parts)
                .font(.system(size: 11))
                .foregroundColor(item.textColor.opacity(0.6))
                .lineLimit(1)
        }
    }

    private var attributionText: String {
        var segments: [String] = []
        if !item.bookTitle.isEmpty {
            segments.append(item.bookTitle)
        }
        if !item.author.isEmpty {
            segments.append(item.author)
        }
        return segments.joined(separator: " · ")
    }
}
