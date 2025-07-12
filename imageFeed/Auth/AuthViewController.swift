//
//  AuthViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 25/05/25.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueId = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear: AuthViewController")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueId {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueId)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack") // 4
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        print("AuthViewController.webViewViewController: code = \(code)")
        
        UIBlockingProgressHUD.show()
        
        let authTokenFetched: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                
                print("AuthViewController.authTokenFetched")
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                    case .success(let token):
                        OAuth2TokenStorage.shared.token = token
                        self.switchToTabBarController()
                    case .failure(let error):
                        print("Ошибка: \(error)")
                        
                        // Показ UIAlertController с ошибкой
                        let alert = UIAlertController(
                            title: "Что-то пошло не так(",
                            message: "Не удалось войти в систему",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
            }
        }
        
        OAuth2Service.shared.fetchOAuthToken(code, completion: authTokenFetched)
        
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    private func switchToTabBarController() {
        print("AuthViewController.switchToTabBarController")
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else
            {
                assertionFailure("Invalid Configuration")
                return
            }
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
        }
    }
}
