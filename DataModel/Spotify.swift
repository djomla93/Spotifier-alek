//
//  Spotify.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 5.6.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation
import SwiftyOAuth

final class Spotify {

	static let shared = Spotify()
	private init() {
	}

	fileprivate let oauthProvider = Provider.spotify(clientID: "badf9c13b4604dd3b6f3335df4542100",
	                                                 clientSecret: "a889c1f8e98f4e07a93fbb56ce5d19a5")

	fileprivate var queuedRequests: [APIRequest] = []
	fileprivate var isFetchingOAuthToken = false {
		didSet {
			if isFetchingOAuthToken { return }
			processQueuedRequests()
		}
	}
}

typealias JSON = [String: Any]

enum SpotifyError: Swift.Error {
	case invalidResponse
	case noData
	case invalidJSON
	case networkError(urlError: URLError?)
}


/*

	Web API user guide:
	https://developer.spotify.com/web-api/user-guide/

	Authorization Guide:
	https://developer.spotify.com/web-api/authorization-guide/

*/

extension Spotify {
	enum SearchType: String {
		case artist
		case album
		case track
		case playlist
	}

	enum DatePrecision: String {
		case year
		case day
	}

	///	This models various items that can be requested for the given main entity
	///	For examples, see Path.artists
	enum ItemType: String {
		case albums = "albums"
		case topTracks = "top-tracks"
		case relatedArtists = "related-artists"
	}

	enum Path {
		//	https://developer.spotify.com/web-api/search-item/
		case search(term: String, type: SearchType)

		//	https://developer.spotify.com/web-api/get-artist/
		//	/artists/{id}
		//	/artists/{id}/albums
		//	/artists/{id}/top-tracks
		//	/artists/{id}/related-artists
		case artists(id: String, type: ItemType?)

		//	https://developer.spotify.com/web-api/get-album/

		//	https://developer.spotify.com/web-api/get-several-albums/

		//	https://developer.spotify.com/web-api/get-albums-tracks/

		//	https://developer.spotify.com/web-api/add-tracks-to-playlist/


		private var method: Spotify.Method {
			switch self {
			case .search, .artists:
				return .GET
			}
		}

		private var headers: [String: String] {
			return Spotify.commonHeaders
		}

		private var fullURL: URL {
			var path = ""

			switch self {
			case .search:
				path = "search"
			case .artists(let id, let type):
				path = "artists/\( id )"
				//	if itemType is present, add it to the URL
				if let type = type {
					path = "\( path )/\( type )"
				}
			}

			return baseURL.appendingPathComponent(path)
		}

		private var params: [String: String] {
			var p : [String: String] = [:]

			switch self {
			case .search(let term, let type):
				p["q"] = term
				p["type"] = type.rawValue
			case .artists:
				break
			}

			return p
		}

		private var encodedParams: String {
			switch self {
			case .search:
				return queryEncoded(params: params)
			case .artists:
				return ""
			}
		}

		private func queryEncoded(params: [String: String]) -> String {
			if params.count == 0 { return "" }

			var arr = [String]()
			for (key, value) in params {
				let s = "\(key)=\(value)"
				arr.append(s)
			}

			return arr.joined(separator: "&")
		}

		private func jsonEncoded(params: [String: String]) -> Data? {
			return try? JSONSerialization.data(withJSONObject: params)
		}

		fileprivate var urlRequest: URLRequest {
			guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else { fatalError("Invalid URL") }

			switch method {
			case .GET:
				components.query = queryEncoded(params: params)
			default:
				break
			}

			guard let url = components.url else { fatalError("Invalid URL") }
			var r = URLRequest(url: url)
			r.httpMethod = method.rawValue
			r.allHTTPHeaderFields = headers

			switch method {
			case .POST:
				r.httpBody = jsonEncoded(params: params)
				break
			default:
				break
			}

			return r
		}
	}
}


extension Spotify {
	typealias Callback = ( JSON?, SpotifyError? ) -> Void

	func call(path: Path, callback: @escaping Callback) {

		let apiRequest = (path, callback)
		oauth(apiRequest: apiRequest) {
			[unowned self] authRequest, localCallback in
			self.execute(urlRequest: authRequest, path: path, callback: localCallback)
		}
	}


}


fileprivate extension Spotify {
	typealias APIRequest = (path: Path, callback: Callback)

	func processQueuedRequests() {
		for apiReq in queuedRequests {
			oauth(apiRequest: apiReq) {
				[weak self] urlRequest, callback in
				self?.execute(urlRequest: urlRequest, path: apiReq.path, callback: callback)
			}
		}
	}

	func oauth(apiRequest: APIRequest, completion: @escaping (URLRequest, @escaping Callback) -> Void) {
		var req = apiRequest.path.urlRequest

		if isFetchingOAuthToken {
			queuedRequests.append( apiRequest )
			return
		}

		guard let token = oauthProvider.token else {
			queuedRequests.append( apiRequest )
			fetchToken()
			return
		}

		if !token.isValid {
			queuedRequests.append( apiRequest )
			refreshToken()
			return
		}

		switch (token.tokenType ?? .bearer) {
		case .bearer:
			req.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
		}

		completion(req, apiRequest.callback)
	}

	func fetchToken() {
		isFetchingOAuthToken = true

		oauthProvider.authorize {
			[weak self] result in
			guard let `self` = self else { return }

			switch result {
			case .success:
				self.isFetchingOAuthToken = false
			case .failure:
				//	TO-DO: Token fetch returned an error
				break
			}
		}

	}

	func refreshToken() {
		fetchToken()
	}

	func execute(urlRequest: URLRequest, path: Path, callback: @escaping Callback) {

		let task = URLSession.shared.dataTask(with: urlRequest) {
			[unowned self]
			data, urlResponse, error in

			//	process the returned stuff, now
			if let error = error as? URLError {
				//	TODO: check error type
				callback(nil, SpotifyError.networkError(urlError: error))
				return
			}

			guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
				callback(nil, SpotifyError.invalidResponse)
				return
			}

			if httpURLResponse.statusCode != 200 {
				switch httpURLResponse.statusCode {
				case 401:	//	Unauthorized, invalid token
					self.oauthProvider.invalidateToken()
					self.call(path: path, callback: callback)
				default:
					callback(nil, SpotifyError.invalidResponse)
				}
				return
			}

			guard let data = data else {
				callback(nil, SpotifyError.noData)
				return
			}

			guard
				let obj = try? JSONSerialization.jsonObject(with: data),
				let json = obj as? JSON
				else {
					callback(nil, SpotifyError.invalidJSON)
					return
			}

			callback(json, nil)
		}

		task.resume()
	}
}


fileprivate extension Spotify {

	static let baseURL : URL = {
		guard let url = URL(string: "https://api.spotify.com/v1/") else { fatalError("Can't create base URL!") }
		return url
	}()

	static let commonHeaders: [String: String] = {
		return [
			"User-Agent": "Spotifier/1.0",
			"Accept": "application/json",
			"Accept-Charset": "utf-8",
			"Accept-Encoding": "gzip, deflate"
		]
	}()

	enum Method: String {
		case GET, POST, PUT, DELETE, HEAD
	}


}


