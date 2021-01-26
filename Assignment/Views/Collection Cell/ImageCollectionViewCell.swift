//
//  File.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    var photo: Photo? = nil
    
    func loadThumbImage(_ data: Photo?){
        photo = data
        guard let photo = photo, let thumbnailURL = photo.previewURL else {
            return
        }
        self.imageView.sd_setImage(with: URL(string: thumbnailURL), placeholderImage: #imageLiteral(resourceName: "ic_placeholder"))
    }
    
    func loadFullImage(_ data: Photo?){
        photo = data
        guard let photo = photo, let fullImageURL = photo.largeImageURL else {
            return
        }
        self.imageView.sd_setImage(with: URL(string: fullImageURL), placeholderImage: #imageLiteral(resourceName: "ic_placeholder"))
    }
}
