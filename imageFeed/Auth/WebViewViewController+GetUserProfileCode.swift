//
//  WebViewController_Ext1.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/06/25.
//

import Foundation
import WebKit

extension WebViewViewController {
    static var webViewCallsCounter: Int = 0
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        
        WebViewViewController.webViewCallsCounter += 1
        print("C = \(WebViewViewController.webViewCallsCounter), NavA = \(navigationAction)")
        
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            print("1")
            decisionHandler(.cancel)
            
        } else {
            print("2")
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
