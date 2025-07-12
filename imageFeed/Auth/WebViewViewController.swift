//
//  WebViewViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 25/05/25.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WKNavigationDelegate, WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?

    private var estimatedProgressObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.accessibilityIdentifier = "UnsplashWebView"
        
        print("WebViewViewController: View Did Load Enter...")
        
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self else { return }
                presenter?.didUpdateProgressValue(webView.estimatedProgress)
            })

        presenter?.viewDidLoad()
        
        print("WebViewViewController: View Did Load Exit...")
    }

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

