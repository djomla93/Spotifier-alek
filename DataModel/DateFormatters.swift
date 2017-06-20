//
//  DateFormatters.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 8.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation

extension DateFormatter {

	//	these are independent of the current app locale
	//	use them for API, JSON conversions

	static let iso8601Formatter: DateFormatter = {
		let df = DateFormatter()
		df.locale = Locale(identifier: "en_US_POSIX")
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"	//	+01:00, ZZZZZ
		return df
	}()

	static let noTimeZoneFormatter: DateFormatter = {
		let df = DateFormatter()
		df.locale = Locale(identifier: "en_US_POSIX")
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		return df
	}()

	static let iso8601FractionalSecondsFormatter: DateFormatter = {
		let df = DateFormatter()
		df.locale = Locale(identifier: "en_US_POSIX")
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return df
	}()




	static let spotifyDayFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		return df
	}()

	static let spotifyYearFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy"
		return df
	}()
}
