//
//  SceneDelegate.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var tabBarController: UITabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 위젯 딥링크 처리 (콜드 스타트)
        if let url = connectionOptions.urlContexts.first?.url {
            DispatchQueue.main.async { [weak self] in
                self?.handleDeepLink(url)
            }
        }
        guard let windowScene = scene as? UIWindowScene else { return }

        let realm = Realm.configured()
        seedDefaultTagsIfNeeded(realm: realm)
        WidgetDataStore.syncFavorites(from: realm)

        // Find or create a stub Book for testing
        let stubBook: Book
        if let existing = realm.objects(Book.self).filter("isbn == %@", "stub-demian").first {
            stubBook = existing
        } else {
            stubBook = Book()
            stubBook.title = "데미안"
            stubBook.author = "헤르만 헤세"
            stubBook.isbn = "stub-demian"
            try? realm.write { realm.add(stubBook) }
        }

        let window = UIWindow(windowScene: windowScene)

        // Tab 1: 홈
        let homeVC = ViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "홈",
            image: AppIcon.house.image(pointSize: 22, weight: .regular),
            selectedImage: AppIcon.house.image(pointSize: 22, weight: .semibold)
        )

        // Tab 2: 수집
        let bookVC = BookSelectionViewController()
        let bookNav = UINavigationController(rootViewController: bookVC)
        bookNav.tabBarItem = UITabBarItem(
            title: "수집",
            image: AppIcon.circlePlus.image(pointSize: 22, weight: .regular),
            selectedImage: AppIcon.circlePlus.image(pointSize: 22, weight: .semibold)
        )

        // Tab 3: 설정
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "설정",
            image: AppIcon.user.image(pointSize: 22, weight: .regular),
            selectedImage: AppIcon.user.image(pointSize: 22, weight: .semibold)
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeNav, bookNav, settingsNav]
        tabBar.tabBar.tintColor = AppColor.accent
        tabBar.tabBar.unselectedItemTintColor = AppColor.tabInactive
        tabBar.tabBar.backgroundColor = AppColor.card
        tabBar.tabBar.layer.cornerRadius = 36
        tabBar.tabBar.layer.masksToBounds = true
        tabBar.tabBar.layer.borderWidth = 1
        tabBar.tabBar.layer.borderColor = AppColor.border.cgColor

        self.tabBarController = tabBar
        window.rootViewController = tabBar
        window.makeKeyAndVisible()

        self.window = window
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url)
    }

    // MARK: - Deep Link

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "bookmate",
              url.host == "quote",
              let idString = url.pathComponents.dropFirst().first,
              let objectId = try? ObjectId(string: idString) else { return }

        let realm = Realm.configured()
        guard let quote = realm.object(ofType: Quote.self, forPrimaryKey: objectId),
              let book = quote.book else { return }

        // 홈 탭으로 이동
        tabBarController?.selectedIndex = 0

        guard let homeNav = tabBarController?.viewControllers?.first as? UINavigationController else { return }
        homeNav.popToRootViewController(animated: false)

        let tags = Array(quote.tags).map(\.name)
        let vc = CardCustomizationViewController(
            quoteText: quote.text,
            book: book,
            page: quote.pageNumber.map { String($0) },
            tags: tags,
            isExistingQuote: true,
            cardStyle: quote.cardStyle,
            quoteId: quote.id
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        homeNav.present(nav, animated: true)
    }
}

