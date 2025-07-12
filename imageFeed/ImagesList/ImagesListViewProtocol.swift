//
//  ImagesListViewProtocol.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated()
    func showError(_ message: String)
    func setLoading(_ isLoading: Bool)
}
