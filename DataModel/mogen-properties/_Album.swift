// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Album.swift instead.

import CoreData

// MARK: - Class methods
extension Album {

    public class var entityName: String {
        return "Album"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: entityName)
    }

}

public extension Album {

	public struct Attributes {
		static let albumId = "albumId"
		static let csvAvailableMarkets = "csvAvailableMarkets"
		static let dateReleased = "dateReleased"
		static let dateReleasedPrecision = "dateReleasedPrecision"
		static let imageLink = "imageLink"
		static let labelName = "labelName"
		static let name = "name"
		static let spotifyURI = "spotifyURI"
	}

	public struct Relationships {
		static let artist = "artist"
		static let tracks = "tracks"
	}

    // MARK: - Properties

    @NSManaged public var albumId: String!

    @NSManaged public var csvAvailableMarkets: String?

    @NSManaged public var dateReleased: Date?

    @NSManaged public var dateReleasedPrecision: String!

    @NSManaged public var imageLink: String?

    @NSManaged public var labelName: String?

    @NSManaged public var name: String!

    @NSManaged public var spotifyURI: String?

    // MARK: - Relationships

    @NSManaged public var artist: Artist?

    @NSManaged public var tracks: Set<Track>

}
