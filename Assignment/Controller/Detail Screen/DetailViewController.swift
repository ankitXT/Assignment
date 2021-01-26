//
//  DetailViewController.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//

import UIKit

private struct DetailViewControllerConstants{
    static let cellIdentifier = "ImageCollectionViewCell"
}


class DetailViewController: UICollectionViewController {
    var photosDataSource: [Photo]? = []
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .left, animated: false)

    }
}

// MARK: - UICollectionViewDataSource implementation
extension DetailViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photosDataSource?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailViewControllerConstants.cellIdentifier, for: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photosDataSource![indexPath.item]
        (cell as! ImageCollectionViewCell).loadFullImage(photo)
                
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
}
