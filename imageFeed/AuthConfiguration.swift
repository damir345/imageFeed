//
//  Constants.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 22/05/25.
//

import Foundation

enum Constants {
    static let accessKey = "1yADKLIFNF8xtYZn4p-occb_SU9llBEXAgMGZOTbzUs"
    static let secretKey = "58P7Yih1KU8g213pdXxKXclZVGYvb4NZoeXX3E-3bUM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    static let getUsernameURL = "https://api.unsplash.com/users/"
    static let oauthAuthorizePath = "/oauth/authorize/native"

    static var photosURL: URL {
        defaultBaseURL.appendingPathComponent("photos")
    }

    static func likePhotoURL(for photoId: String) -> URL {
        defaultBaseURL.appendingPathComponent("photos/\(photoId)/like")
    }
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         authURLString: String,
         defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURL = defaultBaseURL
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }

    static var test: AuthConfiguration {
        return AuthConfiguration(accessKey: "test_access_key",
                                 secretKey: "test_secret_key",
                                 redirectURI: "test_redirect_uri",
                                 accessScope: "public",
                                 authURLString: "https://test-auth-url.com",
                                 defaultBaseURL: URL(string: "https://test-api.com")!)
    }
}

