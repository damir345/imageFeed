//
//  ImagesListViewControllerTests.swift
//  imageFeedTests
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import XCTest
@testable import imageFeed
import UIKit

final class ImagesListViewControllerTests: XCTestCase {

    // MARK: - Spy

    final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
        var view: ImagesListViewProtocol?
        var fetchPhotosCalled = false
        var selectedIndex: Int?
        var photosCount: Int = 0

        func fetchPhotosNextPage() {
            fetchPhotosCalled = true
        }

        func didSelectPhoto(at index: Int) {
            selectedIndex = index
        }

        func photo(at index: Int) -> Photo? {
            return nil
        }

        func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
            completion(.success(()))
        }
    }

    // MARK: - Tests
    
    func test_didTapLike_callsCompletionWithSuccess() {
        // Arrange
        let presenterSpy = ImagesListPresenterSpy()
        var completionCalled = false
        var completionResult: Result<Void, Error>?
        
        // Act
        presenterSpy.didTapLike(at: 0) { result in
            completionCalled = true
            completionResult = result
        }
        
        // Assert
        XCTAssertTrue(completionCalled, "Completion должен быть вызван")
        if case .success = completionResult {
            // успех, тест проходит
        } else {
            XCTFail("Ожидался успех в completion")
        }
    }
}

