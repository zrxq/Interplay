//
//  AppDelegate.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/13/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let serviceType = "interplay-jam"

    var window: UIWindow?
    let link = Link()
    lazy var metro = Metronome(link: link)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // auto-lock off
        UIApplication.shared.isIdleTimerDisabled = true

        // net context
        let name: String
        if let storedName = UserDefaults.musicianName {
            name = storedName
        } else {
            name = Musician.factoryDefaultMusicianName()
        }
        
        let context = NetworkingContext(displayName: name, serviceType: AppDelegate.serviceType)
                
        // window
        window = UIWindow()
        window?.backgroundColor = Style.windowBackground
        window?.tintColor = Style.defaultTint
        window?.rootViewController = LobbyViewController(context: context, link: link, metro: metro)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        link.deactivate()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        link.activate()
    }

}

