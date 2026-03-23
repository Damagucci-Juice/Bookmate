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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let realm = Realm.configured()
        seedDefaultTagsIfNeeded(realm: realm)

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

        // Tab 2: 책찾기
        let bookVC = BookSelectionViewController()
        let bookNav = UINavigationController(rootViewController: bookVC)
        bookNav.tabBarItem = UITabBarItem(
            title: "책찾기",
            image: AppIcon.search.image(pointSize: 22, weight: .regular),
            selectedImage: AppIcon.search.image(pointSize: 22, weight: .semibold)
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeNav, bookNav]
        tabBar.tabBar.tintColor = AppColor.accent
        tabBar.tabBar.unselectedItemTintColor = AppColor.tabInactive
        tabBar.tabBar.backgroundColor = AppColor.bg

        window.rootViewController = tabBar
        window.makeKeyAndVisible()

        self.window = window
    }
}

