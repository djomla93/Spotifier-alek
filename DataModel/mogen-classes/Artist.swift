import Foundation
import CoreData
import Marshal
import RTCoreDataStack

@objc(Artist)
public class Artist: NSManagedObject {

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

	required public init?(managedObjectContext moc: NSManagedObjectContext) {
		guard let entity = NSEntityDescription.entity(forEntityName: Artist.entityName, in: moc) else { return nil }
		super.init(entity: entity, insertInto: moc)
	}
}

extension Artist: ManagedObjectType {}

extension Artist: UnmarshalingWithContext {

	public static func value(from object: MarshaledObject, inContext context: NSManagedObjectContext) throws -> Artist {
		guard let mo = Artist(managedObjectContext: context) else {
			throw DataError.coreDataCreateFailed
		}

		do {
			mo.artistId = try object.value(for: "id")
			mo.name = try object.value(for: "name")
			mo.spotifyURI = try? object.value(for: "uri")

			if let arrImages: [JSON] = try? object.value(for: "images"), let image = arrImages.first {
				mo.imageLink = try? image.value(for: "url")
			}

			if let value: Int64 = try? object.value(for: "followers.total") {
				mo.followersCount = value
			}

			if let value: Int64 = try? object.value(for: "popularity") {
				mo.popularity = value
			}

			if let arr: [String] = try? object.value(for: "genres") {
				mo.csvGenres = arr.joined(separator: ",")
			}

			return mo

		} catch let jsonError {
			context.delete(mo)
			throw DataError.jsonError(jsonError as! MarshalError)
		}
	}
}

