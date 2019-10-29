//
//  AppDelegate.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/26/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = ViewController.loadFromStoryboard()
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

public protocol StoryboardLoadable {
    static var storyboardName: String { get }
}

// This implementation of StoryboardLoadable assumes the convention that
//   the UIViewController subclass adopting this protocol has a storyboard
//   file with the same name as the UIViewController subclass.
//
// For example,
//     "class MyViewController: UIViewController, StoryBoardLoadable {}"
//   should have a corresponding "MyViewController.storyboard" file.
//
// The storyboard file should contain a prototype of the UIViewController
//   subclass, and it should be set as the "Initial View Controller".
public extension StoryboardLoadable where Self: UIViewController {
    static var storyboardName: String {
        return String(describing: Self.self)
    }

    static var storyboard: UIStoryboard {
        let bundle = Bundle(for: Self.self)
        return UIStoryboard(name: storyboardName, bundle: bundle)
    }

    static func loadFromStoryboard() -> Self {
        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Error loading \(self) from storyboard")
        }
        return viewController
    }
}
