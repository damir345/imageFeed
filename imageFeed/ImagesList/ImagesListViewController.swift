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

    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        imagesListService.fetchPhotosNextPage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {

            let photo = photos[indexPath.row]
            if let url = URL(string: photo.largeImageURL) {
                viewController.imageURL = url
            }
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard oldCount != newCount else { return }

        photos = imagesListService.photos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
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

// MARK: configCell

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        // Установка изображения через Kingfisher
        if let url = URL(string: photo.thumbImageURL) {
            cell.myImageView.kf.indicatorType = .activity
            cell.myImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder")
            )
        }

        // Дата
        cell.uploadDate.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""

        // Лайк
        let likeImage = UIImage(named: photo.isLiked ? "LikeButtonOn" : "LikeButtonOff")
        cell.likeButton.setImage(likeImage, for: .normal)

        // Градиент
        addGradientToBackground(with: cell)
    }

    private func addGradientToBackground(with cell: ImagesListCell) {
        // Удаляем предыдущие слои (если были)
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
    }
}

// MARK: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        // Получаем indexPath ячейки
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()

        // Отправляем запрос на лайк/дизлайк
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }

            // Скрываем лоадер в любом случае
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                // Обновляем локальный массив с фото
                self.photos = self.imagesListService.photos

                // Обновляем только состояние лайка у нужной ячейки
                let newIsLiked = self.photos[indexPath.row].isLiked
                cell.setIsLiked(newIsLiked)

            case .failure(let error):
                // Показываем алерт об ошибке
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось поставить лайк. Попробуйте позже.\n\(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

