import Foundation
import CoreData
import Marshal
import RTCoreDataStack

@objc(Track)
public class Track: NSManagedObject {

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

	required public init?(managedObjectContext moc: NSManagedObjectContext) {
		guard let entity = NSEntityDescription.entity(forEntityName: Track.entityName, in: moc) else { return nil }
		super.init(entity: entity, insertInto: moc)
	}
}

extension Track: ManagedObjectType {}

extension Track: UnmarshalingWithContext {

	public static func value(from object: MarshaledObject, inContext context: NSManagedObjectContext) throws -> Track {
		guard let mo = Track(managedObjectContext: context) else {
			throw DataError.coreDataCreateFailed
		}

		do {
			mo.trackId = try object.value(for: "id")
			mo.name = try object.value(for: "name")
			mo.spotifyURI = try? object.value(for: "uri")

			if let arrImages: [JSON] = try? object.value(for: "images"), let image = arrImages.first {
				mo.imageLink = try? image.value(for: "url")
			}

			if let value: Bool = try? object.value(for: "explicit") {
				mo.isExplicit = value
			}

			if let value: Int32 = try? object.value(for: "duration_ms") {
				mo.durationMilliseconds = value
			}

			if let value: Int64 = try? object.value(for: "popularity") {
				mo.popularity = value
			}

			if let value: Int16 = try? object.value(for: "disc_number") {
				mo.discNumber = value
			}
			if let value: Int16 = try? object.value(for: "track_number") {
				mo.trackNumber = value
			}

			if let arr: [String] = try? object.value(for: "available_markets") {
				mo.csvAvailableMarkets = arr.joined(separator: ",")
			}


			return mo

		} catch let jsonError {
			context.delete(mo)
			throw DataError.jsonError(jsonError as! MarshalError)
		}
	}
}

