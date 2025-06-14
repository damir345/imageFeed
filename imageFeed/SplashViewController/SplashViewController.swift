//
//  SplashViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 27/05/25.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if SplashScreenCallsCounter.shared.Counter == 0 {
            OAuth2TokenStorage.shared.clearToken()
        }
        SplashScreenCallsCounter.shared.Counter += 1
        if OAuth2TokenStorage.shared.token != nil {
            switchToTabBarController()
        } else {
            // Show Auth Screen
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                assertionFailure("Failed to instantiate AuthViewController from storyboard")
                return
            }
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
            
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        
        fetchProfile(token)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    func switchToTabBarController() {
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

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                print("FetchOauthToken error")
                break
            }
        }
    }
}

