//
//  AppDelegate.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import Kingfisher
import FirebaseCore
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()

        // 기존 Realm DB를 App Group 공유 컨테이너로 마이그레이션
        SharedRealmConfig.migrateToSharedContainerIfNeeded()

        // Kingfisher 메모리 캐시: 50MB 제한, 이미지 150개 제한
        ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        ImageCache.default.memoryStorage.config.countLimit = 150
        // 디스크 캐시: 200MB 제한, 7일 만료
        ImageCache.default.diskStorage.config.sizeLimit = 200 * 1024 * 1024
        ImageCache.default.diskStorage.config.expiration = .days(7)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

