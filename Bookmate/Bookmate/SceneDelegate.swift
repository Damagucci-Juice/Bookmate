//
//  SceneDelegate.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let bookSelectionVC = BookSelectionViewController()
        let navigationController = UINavigationController(rootViewController: bookSelectionVC)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}

