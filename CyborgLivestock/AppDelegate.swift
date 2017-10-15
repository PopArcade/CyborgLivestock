//
//  AppDelegate.swift
//  CyborgLivestock
//
//  Created by Ryan Poolos on 10/14/17.
//  Copyright © 2017 PopArcade. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()

        return true
    }

}

