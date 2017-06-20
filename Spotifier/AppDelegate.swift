//
//  AppDelegate.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 29.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import RTCoreDataStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var coreDataStack: RTCoreDataStack?

	var spotifyManager: Spotify?
	var dataManager: DataManager?

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		spotifyManager = Spotify.shared

		coreDataStack = RTCoreDataStack {
			[unowned self] in

			self.configureManagers()

			let dependency = Dependency(coreDataContext: self.coreDataStack!.mainContext,
			                            dataManager: self.dataManager)

			if let nc = self.window?.rootViewController as? UINavigationController {
				if let vc = nc.topViewController as? ArtistGridController {
					vc.dependency = dependency
				}
			}


//			self.dataManager?.search(for: "taylor", type: .artist, callback: {
//				count, _ in
//				print(count)
//			})
		}

		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
}


extension AppDelegate {
	func configureManagers() {
		guard let cds = coreDataStack, let sm = spotifyManager else {
			fatalError()
		}

		dataManager = DataManager(coreDataStack: cds, spotifyManager: sm)
	}
}

