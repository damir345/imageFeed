//
//  ProfileViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 5/05/25.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private var presenter: ProfilePresenterProtocol!

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupLayout()
        presenter.viewDidLoad()
    }

    private func setupLayout() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        logoutButton.accessibilityIdentifier = "logoutButton"

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    @objc private func logoutButtonTapped() {
        presenter.didTapLogout()
    }

    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

// MARK: - ProfileViewProtocol

extension ProfileViewController: ProfileViewProtocol {

    func updateProfile(name: String?, login: String?, bio: String?) {
        nameLabel.text = name
        loginLabel.text = login
        descriptionLabel.text = bio
    }

    func updateAvatar(url: URL?) {
        guard let url else { return }
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder.jpeg"))
    }

    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            ProfileLogoutService.shared.logout {
                self?.switchToSplashViewController()
            }
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        present(alert, animated: true)
    }
}
