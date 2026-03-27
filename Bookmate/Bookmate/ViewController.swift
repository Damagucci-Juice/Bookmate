//
//  ViewController.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import SnapKit
import RealmSwift
import RxSwift
import RxCocoa

// MARK: - HomeViewController

class ViewController: UIViewController {

    private let quoteRepository = QuoteRepository()
    private let disposeBag = DisposeBag()

    // MARK: - Content

    // MARK: - Greeting Section

    private let greetingSection = UIView()
    private let logoLabel: UILabel = {
        let label = UILabel()
        let text = "Bookmate"
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: AppFont.logo.font,
                .foregroundColor: AppColor.textPrimary,
                .kern: AppFont.Spacing.logoLetterSpacing
            ]
        )
        return label
    }()

    private let notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: AppIcon.bell.sfSymbolName, withConfiguration: config), for: .normal)
        btn.tintColor = AppColor.textSecondary
        return btn
    }()

    // MARK: - Curation Section (수집한 문장)

    private let curationHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    private let curationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "수집한 문장"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AppColor.textPrimary
        return label
    }()
    private let seeAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("전체보기", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(AppColor.accent, for: .normal)
        return btn
    }()

    private let quoteWheelView = QuoteWheelView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bg
        setupHierarchy()
        setupConstraints()
        loadQuotes()
        seeAllButton.addTarget(self, action: #selector(seeAllQuotesTapped), for: .touchUpInside)
    }

    @objc private func seeAllQuotesTapped() {
        let vc = QuoteListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadQuotes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupHierarchy() {
        // Greeting
        greetingSection.addSubview(logoLabel)
        greetingSection.addSubview(notificationButton)
        view.addSubview(greetingSection)

        // Curation (수집한 문장)
        curationHeaderStack.addArrangedSubview(curationTitleLabel)
        curationHeaderStack.addArrangedSubview(seeAllButton)
        view.addSubview(curationHeaderStack)
        view.addSubview(quoteWheelView)
    }

    private func setupConstraints() {
        let sideInset: CGFloat = 20

        // MARK: Greeting Section
        greetingSection.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        logoLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        notificationButton.snp.makeConstraints {
            $0.centerY.equalTo(logoLabel)
            $0.trailing.equalToSuperview()
        }

        // MARK: Curation Header
        curationHeaderStack.snp.makeConstraints {
            $0.top.equalTo(greetingSection.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }

        // MARK: Quote Wheel — fills remaining screen
        quoteWheelView.snp.makeConstraints {
            $0.top.equalTo(curationHeaderStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
    }

    // MARK: - Data

    private func loadQuotes() {
        // TODO: Replace mock data with real Realm data
        // quoteRepository.fetchAll()
        //     .take(1)
        //     .observe(on: MainScheduler.instance)
        //     .subscribe(onNext: { [weak self] quotes in ... })
        //     .disposed(by: disposeBag)

        let mockItems = Self.mockQuotes()
        quoteWheelView.configure(with: mockItems)
    }

    private static func mockQuotes() -> [WheelQuoteItem] {
        let data: [(String, String)] = [
            ("우리가 두려워해야 할 유일한 것은 두려움 그 자체이다. 용기란 두려움이 없는 것이 아니라 두려움보다 중요한 것이 있다고 판단하는 것이다. 자유를 향한 긴 여정에서 나는 수없이 넘어졌지만 매번 다시 일어나는 법을 배웠다. 어둠 속에서도 빛을 찾아가는 여정이 바로 인생이 우리에게 주는 가장 큰 선물이다.",
             "넬슨 만델라 · 자유를 향한 긴 여정"),
            ("사막이 아름다운 것은 어딘가에 우물을 숨기고 있기 때문이야. 중요한 것은 눈에 보이지 않아. 오직 마음으로만 잘 볼 수 있지. 어른들은 언제나 숫자를 좋아하지. 새로운 친구가 생겼다고 말하면 어른들은 정말 중요한 것에 대해서는 절대로 묻지 않거든. 네가 무언가를 길들였다면 그것에 대해 너는 영원히 책임을 져야만 해.",
             "생텍쥐페리 · 어린 왕자"),
            ("인생이란 자전거를 타는 것과 같다. 균형을 잡으려면 계속 움직여야 한다. 상상력은 지식보다 중요하다. 지식에는 한계가 있지만 상상력은 세상의 모든 것을 끌어안을 수 있기 때문이다. 과거에서 배우고 오늘을 위해 살며 미래에 대한 희망을 결코 버리지 마라.",
             "아인슈타인 · 명언집"),
            ("진정한 발견의 여행은 새로운 풍경을 찾는 것이 아니라 새로운 눈을 갖는 것이다. 과거는 우리 안에 고스란히 살아 있으며 기억의 조각들은 한 잔의 차 향기 속에서도 다시 피어오른다. 우리가 사랑했던 장소와 사람들은 시간이 흘러도 마음속에 영원히 머무른다.",
             "프루스트 · 잃어버린 시간을 찾아서"),
            ("모든 행복한 가정은 서로 닮았고 불행한 가정은 제각각의 이유로 불행하다. 사랑이란 상대방의 행복을 나의 행복과 동일시하는 것이다. 진정한 사랑은 끝이 없으며 우리의 마음을 더 넓고 깊게 만들어 준다. 용서는 사랑의 가장 숭고한 형태이며 그것 없이는 진정한 관계란 존재할 수 없다.",
             "톨스토이 · 안나 카레니나"),
            ("삶이 있는 한 희망은 있다. 그리고 희망이 있는 곳에 반드시 길이 있다. 절망의 끝에서도 한 줄기 빛은 반드시 찾아온다. 포기하지 않는 한 우리는 언제나 다시 시작할 수 있다. 인간의 위대함은 역경 속에서 피어나는 꽃과 같아서 시련이 클수록 더 아름다운 빛을 발한다.",
             "키케로 · 의무론"),
            ("나는 생각한다, 고로 존재한다. 의심할 수 없는 것은 의심하고 있는 나 자신의 존재뿐이다. 모든 확실한 지식의 출발점은 바로 여기에, 생각하는 나 자신에게 있다. 이성의 빛으로 세상을 밝혀야 한다. 진리를 향한 여정에서 우리는 모든 선입견을 버려야만 한다.",
             "데카르트 · 방법서설"),
            ("새는 알에서 나오려고 투쟁한다. 알은 세계이다. 태어나려는 자는 하나의 세계를 깨뜨려야 한다. 새는 신에게로 날아간다. 그 신의 이름은 아브락사스이다. 각자의 삶에는 오직 하나의 진정한 소명이 있다. 그것은 자기 자신에게 이르는 길을 찾는 것이다.",
             "헤르만 헤세 · 데미안"),
            ("자연은 가장 단순한 수단으로 가장 위대한 결과를 만들어낸다. 오늘 할 수 있는 일에 전력을 다하라. 그러면 내일에는 한 걸음 더 진보한다. 내가 더 멀리 볼 수 있었던 것은 거인들의 어깨 위에 서 있었기 때문이다. 진리는 항상 단순함 속에 숨어 있다.",
             "뉴턴 · 프린키피아"),
            ("우리가 어떤 사람인지는 우리가 반복해서 하는 행동에 달려 있다. 그러므로 탁월함은 행위가 아니라 습관이다. 행복은 자기 자신에게 달려 있다. 교육의 뿌리는 쓰지만 그 열매는 달다. 덕은 과잉과 부족 사이의 중용에 있으며 이를 실천하는 것이 진정한 지혜이다.",
             "아리스토텔레스 · 니코마코스 윤리학"),
            ("가장 어두운 밤도 끝나고 태양은 다시 떠오른다. 인생에서 가장 위대한 영광은 결코 넘어지지 않는 것이 아니라 넘어질 때마다 다시 일어나는 데 있다. 선한 행동은 아무리 작아도 결코 헛되지 않는다. 사랑하는 것은 천국의 한 조각을 엿보는 것이다.",
             "빅토르 위고 · 레 미제라블"),
            ("네가 무언가를 간절히 원할 때, 온 우주는 네가 그것을 이룰 수 있도록 도와준다. 배움의 비결은 두려움 없이 실수하는 것이다. 꿈을 실현할 가능성이 있기에 삶은 흥미로운 것이다. 자신의 운명을 사랑하고 그것을 변화시킬 용기를 가져라.",
             "파울로 코엘료 · 연금술사"),
            ("아름다움이 세상을 구원할 것이다. 고통은 우리가 살아있다는 증거이며 그것을 통해 우리는 더 깊은 사람이 된다. 진정한 자유는 자신의 내면에서 시작된다. 영혼의 비밀은 고통을 통해서만 열리는 문 뒤에 숨겨져 있으며 그 문을 여는 열쇠는 사랑이다.",
             "도스토옙스키 · 카라마조프 가의 형제들"),
            ("세상에서 가장 큰 감옥은 자기 자신의 마음이다. 자유는 마음속에서 시작된다. 원한은 독약을 마시면서 상대방이 죽기를 바라는 것과 같다. 교육은 세상을 바꿀 수 있는 가장 강력한 무기이다. 용기란 두려워하지 않는 것이 아니라 두려움을 극복하는 것이다.",
             "넬슨 만델라 · 나 자신과의 대화"),
            ("전쟁터에서 나는 아무것도 영웅적인 것을 본 적이 없다. 영웅이란 자신이 할 수 있는 일을 하는 사람일 뿐이다. 세상은 고통으로 가득하지만 그것을 극복한 사례로도 가득하다. 한 사람의 이야기를 들을 때 우리는 비로소 진정한 공감을 시작할 수 있다.",
             "에리히 마리아 레마르크 · 서부 전선 이상 없다"),
            ("같은 강물에 두 번 발을 담글 수 없다. 만물은 유전하고 어떤 것도 영원히 머무르지 않는다. 변화만이 유일한 상수이다. 대립하는 것들의 조화 속에서 가장 아름다운 질서가 탄생한다. 눈에 보이지 않는 조화가 눈에 보이는 조화보다 더 강하다.",
             "헤라클레이토스 · 단편집"),
            ("인간은 자유롭도록 선고받았다. 우리는 선택의 무게를 짊어지고 살아가야 한다. 실존은 본질에 앞선다. 타인은 지옥이다. 인간은 먼저 존재하고 그 다음에 자신을 만들어간다. 자유는 우리가 피할 수 없는 운명이며 그것이 바로 인간 존재의 핵심이다.",
             "사르트르 · 존재와 무"),
            ("삶이란 가까이서 보면 비극이지만, 멀리서 보면 희극이다. 웃음 없는 하루는 낭비된 하루이다. 거울은 생각하지 않고 비추기만 하듯이 우리도 있는 그대로의 세상을 바라볼 줄 알아야 한다. 인생에서 가장 필요한 것은 용기와 상상력, 그리고 약간의 돈이다.",
             "찰리 채플린 · 나의 자서전"),
            ("기하학에는 왕도가 없다. 배움에 지름길은 없으며 끊임없이 묻고 탐구하는 자만이 진리에 다가갈 수 있다. 점은 부분이 없는 것이며 선은 폭이 없는 길이이다. 가장 단순한 공리에서 출발하여 가장 복잡한 진리에 도달할 수 있다는 것이 수학의 아름다움이다.",
             "유클리드 · 기하학 원론"),
            ("자연의 법칙은 어둠 속에 숨겨져 있었다. 신이 말씀하셨다, 뉴턴이 있으라. 그리하여 모든 것이 빛이 되었다. 내가 더 멀리 볼 수 있었던 것은 거인들의 어깨 위에 서 있었기 때문이다. 진리의 대양은 아직 발견되지 않은 채 내 앞에 펼쳐져 있다.",
             "아이작 뉴턴 · 편지"),
        ]

        let palette = AppColor.WheelCard.palette
        return data.enumerated().map { (index, pair) in
            let bg = palette[index % palette.count]
            let textColor = textColorForBackground(bg)
            return WheelQuoteItem(text: pair.0, source: pair.1, backgroundColor: bg, textColor: textColor)
        }
    }

    private static func textColorForBackground(_ bg: UIColor) -> UIColor {
        if bg == AppColor.WheelCard.mutedGreen || bg == AppColor.WheelCard.dustyTeal {
            return .white
        }
        return AppColor.textPrimary
    }
}
