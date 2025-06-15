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
    static let getUsernameURL = "https://api.unsplash.com/users/"
    static let oauthAuthorizePath = "/oauth/authorize/native"
}
