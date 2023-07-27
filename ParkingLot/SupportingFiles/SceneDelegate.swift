//
//  SceneDelegate.swift
//  ParkingLot
//
//  Created by Никита Данилович on 06.06.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let mainCoordinator: MainCoordinatorProtocol = MainCoordinator()
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        mainCoordinator.navigationController = navigationController
        mainCoordinator.initializeAuthentification()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            window.rootViewController = navigationController
        }
        window.rootViewController = launchScreen
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

