//
//  NavigationController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 12.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {

	fileprivate var activeStatusBarStyle: UIStatusBarStyle = .lightContent {
		didSet {
			setNeedsStatusBarAppearanceUpdate()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return activeStatusBarStyle
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.delegate = self
	}
}


fileprivate extension NavigationController {

}


extension NavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController,
	                          willShow viewController: UIViewController,
	                          animated: Bool) {

		activeStatusBarStyle = viewController.preferredStatusBarStyle
	}

	func navigationController(_ navigationController: UINavigationController,
	                          didShow viewController: UIViewController,
	                          animated: Bool) {


	}
}


