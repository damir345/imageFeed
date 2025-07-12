//
//  WebViewPresenter.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 6/07/25.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let progressBarVisibilityThreshold = 0.0001
    private let authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { 
            assertionFailure("Failed to construct authorization URLRequest")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        view?.setProgressValue(Float(newValue))
        let shouldHideProgress = abs(newValue - 1.0) <= progressBarVisibilityThreshold
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Double) -> Bool {
        abs(value - 1.0) <= progressBarVisibilityThreshold
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}



