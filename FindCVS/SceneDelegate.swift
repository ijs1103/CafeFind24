//
//  SceneDelegate.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white

        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.window?.rootViewController = TabBarViewController()
        }
        window?.makeKeyAndVisible()
    }

}

