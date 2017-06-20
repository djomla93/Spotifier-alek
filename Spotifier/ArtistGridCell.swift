//
//  ArtistGridCell.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 14.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class ArtistGridCell: UICollectionViewCell {

	@IBOutlet fileprivate weak var photoView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()

		cleanup()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		cleanup()
	}

	fileprivate func cleanup() {
		photoView.image = nil
	}


	func configure(with artist: Artist) {
		print(artist.name)
	}
}


