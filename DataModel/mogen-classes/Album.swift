import Foundation
import CoreData
import Marshal
import RTCoreDataStack

@objc(Album)
public class Album: NSManagedObject {

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

	required public init?(managedObjectContext moc: NSManagedObjectContext) {
		guard let entity = NSEntityDescription.entity(forEntityName: Album.entityName, in: moc) else { return nil }
		super.init(entity: entity, insertInto: moc)
	}
}

extension Album: ManagedObjectType {}

extension Album {
	var releaseDatePrecision: Spotify.DatePrecision {
		return Spotify.DatePrecision(rawValue: dateReleasedPrecision) ?? .year
	}
}

extension Album: UnmarshalingWithContext {

	public static func value(from object: MarshaledObject, inContext context: NSManagedObjectContext) throws -> Album {
		guard let mo = Album(managedObjectContext: context) else {
			throw DataError.coreDataCreateFailed
		}

		do {
			mo.albumId = try object.value(for: "id")
			mo.name = try object.value(for: "name")
			mo.spotifyURI = try? object.value(for: "uri")
			mo.labelName = try? object.value(for: "uri")

			if let arrImages: [JSON] = try? object.value(for: "images"), let image = arrImages.first {
				mo.imageLink = try? image.value(for: "url")
			}

			if let arr: [String] = try? object.value(for: "available_markets") {
				mo.csvAvailableMarkets = arr.joined(separator: ",")
			}

			/*
			Ok, this is tricky. Release can be either down to the day or all the way up year.
			Need to save that info, so we now what date components to extract from date

			"release_date" : "2013-11-08",
			"release_date_precision" : "day"
			
			"release_date" : "1983",
			"release_date_precision" : "year"
			
			*/
			if let value: Spotify.DatePrecision = try? object.value(for: "release_date_precision") {
				mo.dateReleasedPrecision = value.rawValue
			}
			if let value: String = try? object.value(for: "release_date") {
				switch mo.releaseDatePrecision {
				case .day:
					mo.dateReleased = DateFormatter.spotifyDayFormatter.date(from: value)
				case .year:
					mo.dateReleased = DateFormatter.spotifyYearFormatter.date(from: value)
				}
			}

			return mo

		} catch let jsonError {
			context.delete(mo)
			throw DataError.jsonError(jsonError as! MarshalError)
		}
	}
}

