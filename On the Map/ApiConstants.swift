//
//  ApiConstants.swift
//  On the Map
//
//  Created by X.I. Losada on 27/10/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation


extension ParseApiClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        /// APPLICATION ID
        static let AppId : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: URLs
        static let BaseURL : String = "https://api.parse.com/1/classes/"
        
        static let HeaderApiKey: String = "X-Parse-REST-API-Key"
        
        static let HeaderAppId: String = "X-Parse-Application-Id"
        
    }
    


    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "account"
        static let AccountIDFavoriteMovies = "account/{id}/favorite/movies"
        static let AccountIDFavorite = "account/{id}/favorite"
        static let AccountIDWatchlistMovies = "account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "search/movie"
        
        // MARK: Config
        static let Config = "configuration"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
    }
}