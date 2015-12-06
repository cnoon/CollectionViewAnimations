//
//  AppDelegate.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // MARK: - App State Methods

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = {
            let window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window.rootViewController = ViewController()
            window.backgroundColor = UIColor.whiteColor()
            window.makeKeyAndVisible()

            return window
        }()

        return true
    }
}
