//
//  ImagesListPresenterProtocol.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo?
    func fetchPhotosNextPage()
    func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void)
}
