//
//  ViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 26/04/25.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    private var presenter: ImagesListPresenterProtocol!

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        presenter.fetchPhotosNextPage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter.photo(at: indexPath.row),
           let url = URL(string: photo.largeImageURL) {

            viewController.imageURL = url
        }
    }
}

// MARK: - ImagesListViewProtocol

extension ImagesListViewController: ImagesListViewProtocol {

    func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = presenter.photosCount
        guard oldCount != newCount else { return }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: cell, with: indexPath)
        cell.delegate = self
        return cell
    }
}

// MARK: - ConfigCell

extension ImagesListViewController {

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter.photo(at: indexPath.row) else { return }

        if let url = URL(string: photo.thumbImageURL) {
            cell.myImageView.kf.indicatorType = .activity
            cell.myImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder")
            )
        }

        cell.uploadDate.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""

        let likeImage = UIImage(named: photo.isLiked ? "LikeButtonOn" : "LikeButtonOff")
        cell.likeButton.setImage(likeImage, for: .normal)

        addGradientToBackground(with: cell)
    }

    private func addGradientToBackground(with cell: ImagesListCell) {
        cell.gradientView.layer.sublayers?.removeAll()

        let gradient = CAGradientLayer()
        gradient.frame = cell.gradientView.bounds
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)

        cell.gradientView.layer.cornerRadius = 16
        cell.gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.gradientView.clipsToBounds = true

        cell.gradientView.layer.insertSublayer(gradient, at: 0)
        
        cell.gradientView.isUserInteractionEnabled = false
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter.photo(at: indexPath.row) else {
            return UITableView.automaticDimension
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !AppUtils.isUITestRunning else { return }
        if indexPath.row == presenter.photosCount - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        UIBlockingProgressHUD.show()

        presenter.didTapLike(at: indexPath.row) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    if let newIsLiked = self?.presenter.photo(at: indexPath.row)?.isLiked {
                        cell.setIsLiked(newIsLiked)
                    }
                case .failure(let error):
                    self?.showError("Не удалось поставить лайк. Попробуйте позже.\n\(error.localizedDescription)")
                }
            }
        }
    }
}

