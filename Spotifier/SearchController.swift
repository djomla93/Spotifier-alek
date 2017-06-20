//
//  SearchController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 12.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import CoreData

final class SearchController: UIViewController, StoryboardLoadable, NeedsDependency {

	var dependency: Dependency? {
		didSet {
			if !self.isViewLoaded { return }
			prepareDataSource()
		}
	}

	fileprivate var moc: NSManagedObjectContext? {
		return dependency?.coreDataContext
	}
	fileprivate var dataManager: DataManager? {
		return dependency?.dataManager
	}

	fileprivate var frc: NSFetchedResultsController<Artist>?
	fileprivate var searchTerm: String? {
		didSet {
			prepareDataSource()
			initiateSearch()
		}
	}

	@IBOutlet fileprivate weak var collectionView: UICollectionView!

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		let searchNib = UINib(nibName: "SearchCell", bundle: nil)
		collectionView.register(searchNib, forCellWithReuseIdentifier: "SearchCell")
    }
}


fileprivate extension SearchController {
	func initiateSearch() {
		guard let dataManager = dataManager, let searchTerm = searchTerm else { return }
		dataManager.search(for: searchTerm, type: .artist) {
			[weak self] count, dataError in
			//
		}
	}

	func prepareDataSource() {
		guard let moc = moc, let searchTerm = searchTerm else {
			frc = nil
			collectionView.reloadData()
			return
		}

		let sort = NSSortDescriptor(key: Artist.Attributes.name, ascending: true)
		let sort2 = NSSortDescriptor(key: Artist.Attributes.artistId, ascending: false)

		let predicate = NSPredicate(format: "%K contains[cd] %@", Artist.Attributes.name, searchTerm)
		frc = Artist.fetchedResultsController(in: moc, predicate: predicate, sortedWith: [sort, sort2])

		frc?.delegate = self

		if ((try? frc?.performFetch()) != nil) {
			collectionView.reloadData()
		}
	}
}


extension SearchController: NSFetchedResultsControllerDelegate {

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		//	reload labels, buttons, views etc
		collectionView.reloadData()
	}
}








extension SearchController: UICollectionViewDataSource {

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
		let cell: SearchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell

		//	configure
		let artist = frc!.object(at: indexPath)
//		cell.configure(with: artist)

		return cell
	}
}

extension SearchController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {

		let bounds = collectionView.bounds
		let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

		var size = flowLayout.itemSize
		size.width = bounds.width
		return size
	}
	
}



extension SearchController {

	@IBAction func didChangeTextField(_ sender: UITextField) {
		guard let str = sender.text else {
			searchTerm = nil
			return
		}

		if str.characters.count == 0 {
			searchTerm = nil
			return
		}

		searchTerm = str
	}
}


