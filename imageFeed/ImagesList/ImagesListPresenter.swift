//
//  ImagesListPresenter.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {

    weak var view: ImagesListViewProtocol?

    private let imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []

    private var isLoading = false

    var photosCount: Int {
        photos.count
    }

    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < photos.count else { return nil }
        return photos[index]
    }

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        view?.setLoading(true)

        imagesListService.fetchPhotosNextPage()

        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated()
            self.isLoading = false
            self.view?.setLoading(false)
        }
    }

    func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard index >= 0 && index < photos.count else {
            completion(.failure(NSError(domain: "Index out of range", code: 0)))
            return
        }
        let photo = photos[index]

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success:
                self?.photos = self?.imagesListService.photos ?? []
            case .failure:
                break
            }
            completion(result)
        }
    }
}
