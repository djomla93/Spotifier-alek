//
//  DataManager-Notifications.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 19.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation

//	iOS SDK way:
extension Notification.Name {
	static let DataManagerDataPreloadCompleted = "DataManagerDidCompletePreloadDataNotification"
}

//	Recommended way
extension DataManager {
	enum Notify: String {
		case dataPreloadCompleted = "DataManagerDidCompletePreloadDataNotification"

		var name: Notification.Name {
			return Notification.Name(rawValue: self.rawValue)
		}
	}
}
