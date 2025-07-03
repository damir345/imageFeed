//
//  SingleImageViewController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 6/05/25.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {

    var imageURL: URL? {
        didSet {
            guard isViewLoaded else { return }
            loadFullImage()
        }
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var shareButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        loadFullImage()
    }

    private func loadFullImage() {
        guard let imageURL else { return }

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadFullImage()
        })

        present(alert, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()

        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let contentSize = scrollView.contentSize
        let x = (contentSize.width - visibleSize.width) / 2
        let y = (contentSize.height - visibleSize.height) / 2

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }

        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


