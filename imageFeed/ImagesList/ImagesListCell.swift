//
//  ImagesListCell.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 27/04/25.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var uploadDate: UILabel!
    
    @IBOutlet weak var gradientView: UIView!
    
}
