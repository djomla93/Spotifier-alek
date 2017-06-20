//
//  Dependency.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 4.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation
import CoreData

struct Dependency {
	var coreDataContext: NSManagedObjectContext?
	var dataManager: DataManager?

	init(coreDataContext: NSManagedObjectContext? = nil, dataManager: DataManager? = nil) {
		self.coreDataContext = coreDataContext
		self.dataManager = dataManager
	}

	static var empty: Dependency {
		return Dependency()
	}
}

protocol NeedsDependency: class {
	var dependency: Dependency? { get set }
}


