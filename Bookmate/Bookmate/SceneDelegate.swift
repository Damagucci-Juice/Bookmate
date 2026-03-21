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
        let rootVC = BookDetailViewController(book: stubBook)
        let navigationController = UINavigationController(rootViewController: rootVC)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}

