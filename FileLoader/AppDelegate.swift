//
//  AppDelegate.swift
//  FileLoader
//
//  Created by Марат Зайнуллин on 29.01.2020.
//  Copyright © 2020 TMT Soft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window?.rootViewController = ViewController()
        
        return true
    }


}

