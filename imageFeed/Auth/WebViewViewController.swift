//
//  WebViewViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 25/05/25.
//

import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    let progressBarVisibilityThreshold = 0.0001
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?

    /// Новое API для наблюдения за estimatedProgress
    private var estimatedProgressObservation: NSKeyValueObservation?
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("WebViewViewController: ViewWillAppear...")
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        print("WebViewViewController: View Is Appearing...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WebViewViewController: View Did Load Enter...")
        
        webView.navigationDelegate = self
        loadAuthView()
        
        // Подключаем новое KVO
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            })

        updateProgress()
        
        print("WebViewViewController: View Did Load Exit...")
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка создания URLComponents для '\(WebViewConstants.unsplashAuthorizeURLString)'")
            return
        }
        
        print("LoadAuthView requesting OAuth2Token")
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Ошибка получения значения свойства url объекта класса URLComponents")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= progressBarVisibilityThreshold
    }
}
