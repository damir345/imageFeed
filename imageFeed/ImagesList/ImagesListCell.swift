//
//  ImagesListCell.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 27/04/25.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var uploadDate: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    weak var delegate: ImagesListCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.kf.cancelDownloadTask()
        myImageView.image = nil
    }
    
    func configure(with photo: Photo) {
        // Устанавливаем дату
        if let date = photo.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            uploadDate.text = formatter.string(from: date)
        } else {
            uploadDate.text = ""
        }

        // Загружаем изображение
        myImageView.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            myImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder")) { [weak self] _ in
                self?.setNeedsLayout()
            }
        }

        // Обновляем состояние кнопки
        setIsLiked(photo.isLiked)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "LikeButtonOn" : "LikeButtonOff"
        likeButton.setImage(UIImage(named: imageName), for: .normal)

        likeButton.accessibilityIdentifier = "LikeButton"
       
        likeButton.accessibilityLabel = imageName
    }

    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
}
