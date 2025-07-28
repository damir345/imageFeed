//
//  ProfilePresenterProtocol.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}
