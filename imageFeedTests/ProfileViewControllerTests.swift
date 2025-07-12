//
//  ProfileViewControllerTests.swift
//  imageFeedTests
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import XCTest
@testable import imageFeed

final class ProfileViewControllerTests: XCTestCase {
    final class ProfilePresenterSpy: ProfilePresenterProtocol {
        var view: ProfileViewProtocol?
        var viewDidLoadCalled = false
        var logoutCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didTapLogout() {
            logoutCalled = true
        }
    }

    func test_viewDidLoad_callsPresenterViewDidLoad() {
        // arrange
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        // act
        _ = sut.view

        // assert
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func test_logoutButtonTap_callsPresenterLogout() {
        // arrange
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        // act
        _ = sut.view
        let logoutButton = sut.view.subviews.compactMap { $0 as? UIButton }.first
        logoutButton?.sendActions(for: .touchUpInside)

        // assert
        XCTAssertTrue(presenterSpy.logoutCalled, "Ожидалось, что presenter.logout() будет вызван")
    }
}

