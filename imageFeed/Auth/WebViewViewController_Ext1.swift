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
        if
            let url = navigationAction.request.url,                         //1
            let urlComponents = URLComponents(string: url.absoluteString),  //2
            urlComponents.path == "/oauth/authorize/native",                //3
            let items = urlComponents.queryItems,                           //4
            let codeItem = items.first(where: { $0.name == "code" })        //5
        {
            return codeItem.value                                           //6
        } else {
            return nil
        }
    }
}
