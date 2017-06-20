//
//  DataManager.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 5.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation
import CoreData
import RTCoreDataStack
import Marshal

enum DataError: Error {
	case apiError(SpotifyError)
	case invalidJSON

	case coreDataCreateFailed
	case coreDataSaveFailed
	case jsonError(MarshalError)
}

final class DataManager {

	let spotifyManager: Spotify
	let coreDataStack: RTCoreDataStack

	init(coreDataStack: RTCoreDataStack, spotifyManager: Spotify) {
		self.coreDataStack = coreDataStack
		self.spotifyManager = spotifyManager
	}
}




//	MARK:- Data fetches

extension DataManager {
	func fetchUnlovedArtists() -> [Artist] {

		guard let moc = coreDataStack.mainContext else {
			fatalError("Fali ti bre CONTEXT!")
		}

		let fr: NSFetchRequest<Artist> = Artist.fetchRequest()

		let predicate = NSPredicate(format: "%K == 0", Artist.Attributes.followersCount)
		fr.predicate = predicate

		let sort = NSSortDescriptor(key: Artist.Attributes.name, ascending: true)
		let sort2 = NSSortDescriptor(key: Artist.Attributes.artistId, ascending: false)
		fr.sortDescriptors = [sort, sort2]

		let artists = try? moc.fetch(fr)

		return artists ?? []
	}
}




//	MARK:- API wrappers

extension DataManager {
	typealias Callback = (Int, DataError?) -> Void

	//	PRIMER: how to post notifications
	func preload() {
		//	make some API call to preload some data

		//	post notification to inform the rest of the app
//		let name = Notification.Name(Notification.Name.DataManagerDataPreloadCompleted)
//		let userInfo: [String: Any]? = nil
//		let notification = Notification(name: name, object: self, userInfo: userInfo)
//		NotificationCenter.default.post(notification)

		let name = Notify.dataPreloadCompleted.name
		let userInfo: [String: Any]? = nil
		let notification = Notification(name: name, object: self, userInfo: userInfo)
		NotificationCenter.default.post(notification)
	}

	func search(for term: String, type: Spotify.SearchType, callback: @escaping Callback) {

		let path = Spotify.Path.search(term: term, type: type)

		spotifyManager.call(path: path) {
			[unowned self] json, error in

			if let error = error {
				callback(0, DataError.apiError(error))
				return
			}

			guard let json = json else {
				callback(0, DataError.invalidJSON)
				return
			}

			let moc = self.coreDataStack.importerContext()
			var count: Int = 0

			switch type {
			case .artist:
				guard let result = json["artists"] as? JSON else { return }
//				guard let items = result["items"] as? [JSON] else { return }
				do {
					let artists: [Artist] = try result.value(for: "items", inContext: moc)
					let artistIDs: [String] = artists.flatMap({ $0.artistId })

					let predicate = NSPredicate(format: "%K IN %@", Artist.Attributes.artistId, artistIDs)
					let existingObjects = Artist.fetch(in: moc,
					                                   includePending: false,
					                                   predicate: predicate)
					let existingIDs = existingObjects.flatMap({ $0.artistId })

					let updatedArtists = artists.filter({ existingIDs.contains($0.artistId) })

					//	update existing objects
					for io in updatedArtists {
						guard let eo = existingObjects.filter({ $0.artistId == io.artistId }).first else { continue }
						//	update each property, from `io` to `eo`
						eo.name = io.name
						//	...
					}

					//	delete all these `updated`
					//	so they are not saved as new records
					for mo in updatedArtists {
						moc.delete(mo)
					}

					count = artists.count

				} catch let jsonError {
					callback(0, DataError.jsonError(jsonError as! MarshalError))
					return
				}

			case .album:
				break
			case .track:
				break
			case .playlist:
				break
			}

			//	finally, save!
			do {
				if moc.hasChanges {
					try moc.save()
				}
				callback(count, nil)

			} catch let error {
				print("Context Save failed due to: \(error)")
				callback(0, DataError.coreDataSaveFailed)
			}
		}
	}
}




