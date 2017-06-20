// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Artist.swift instead.

import CoreData

// MARK: - Class methods
extension Artist {

    public class var entityName: String {
        return "Artist"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: entityName)
    }

}

public extension Artist {

	public struct Attributes {
		static let artistId = "artistId"
		static let csvGenres = "csvGenres"
		static let followersCount = "followersCount"
		static let imageLink = "imageLink"
		static let name = "name"
		static let popularity = "popularity"
		static let spotifyURI = "spotifyURI"
	}

	public struct Relationships {
		static let albums = "albums"
	}

    // MARK: - Properties

    @NSManaged public var artistId: String!

    @NSManaged public var csvGenres: String?

    @NSManaged public var followersCount: Int64

    @NSManaged public var imageLink: String?

    @NSManaged public var name: String!

    @NSManaged public var popularity: Int64

    @NSManaged public var spotifyURI: String?

    // MARK: - Relationships

    @NSManaged public var albums: Set<Album>

}
