//
//  ArtistGridController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 12.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import CoreData

final class ArtistGridController: UIViewController, NeedsDependency {

	var dependency: Dependency? {
		didSet {
			if let vc = searchController as? NeedsDependency {
				vc.dependency = dependency
			}

			if !self.isViewLoaded { return }
			prepareDataSource()
		}
	}

	fileprivate var moc: NSManagedObjectContext? {
		return dependency?.coreDataContext
	}

	fileprivate var frc: NSFetchedResultsController<Artist>?

	fileprivate var searchController: SearchController?


	@IBOutlet fileprivate weak var collectionView: UICollectionView!



	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		//	reload labels, buttons, views etc

		prepareDataSource()
		setupNotificationHandlers()

		let vc = SearchController.initial()
		vc.dependency = dependency
		show(vc, sender: self)
		searchController = vc
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

fileprivate extension ArtistGridController {
	func setupNotificationHandlers() {
		NotificationCenter.default.addObserver(forName: DataManager.Notify.dataPreloadCompleted.name, object: nil, queue: OperationQueue.main) {
			[weak self] notification in
			guard let `self` = self else { return }

			//	process notification
//			notification.object		//	Any?
//			notification.userInfo	//	[AnyHashable: Any]?

			self.prepareDataSource()
		}
	}
}


fileprivate extension ArtistGridController {
	func prepareDataSource() {
		guard let moc = moc else { return }

		let fr: NSFetchRequest<Artist> = Artist.fetchRequest()

		let sort = NSSortDescriptor(key: Artist.Attributes.name, ascending: true)
		let sort2 = NSSortDescriptor(key: Artist.Attributes.artistId, ascending: false)
		fr.sortDescriptors = [sort, sort2]

		frc = NSFetchedResultsController(fetchRequest: fr,
		                                 managedObjectContext: moc,
		                                 sectionNameKeyPath: nil,
		                                 cacheName: nil)
		frc?.delegate = self

		if ((try? frc?.performFetch()) != nil) {
			collectionView.reloadData()
		}
	}
}


extension ArtistGridController: NSFetchedResultsControllerDelegate {

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		//	reload labels, buttons, views etc
		collectionView.reloadData()
	}
}








extension ArtistGridController: UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let frc = frc else { return 0 }

		guard let sections = frc.sections else { return 0 }
		return sections.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let frc = frc else { return 0 }

		guard let sections = frc.sections else { return 0 }
		return sections[section].numberOfObjects
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell: ArtistGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistGridCell", for: indexPath) as! ArtistGridCell

		//	configure
		let artist = frc!.object(at: indexPath)
		cell.configure(with: artist)

		return cell
	}
}

extension ArtistGridController: UICollectionViewDelegate {

}



