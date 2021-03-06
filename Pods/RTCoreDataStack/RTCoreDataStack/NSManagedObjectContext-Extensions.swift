//
//  NSManagedObjectContext-Extensions.swift
//  RTSwiftCoreDataStack
//
//  Created by Aleksandar Vacić on 24.10.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
	@objc(saveWithCallback:)
	/// Performs save on the given context. Automatically saves its parentContext if available.
	///	If any errors occur, it will return them in the optional callback.
	///
	///	Thus you can simply call this as `moc.save()`
	///
	/// - parameter callback: closure to be informed about possible errors during save. Or simply as pingback so you know where the save is completed.
	///
	public func save(_ callback: @escaping (Error?) -> Void = {_ in}) {
		if !self.hasChanges {
			callback(nil)
		}

		//	async save, to not block the thread it's called on
		self.performAndWait {
			do {
				try self.save()

				//	if there's a parentContext, save that one too
				if let parentContext = self.parent {
					parentContext.save(callback)
					return;
				}

				callback(nil)

			} catch(let error) {
//				let log = String(format: "E | %@:%@/%@ Error saving context:\n%@",
//				                 String(describing: self), #file, #line, error.localizedDescription)
//				print(log)
				callback(error)
			}
		}
	}
}
