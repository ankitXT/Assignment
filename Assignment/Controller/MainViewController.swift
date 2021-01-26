//
//  MainViewController.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit
import Foundation

private struct MainViewControllerConstants{
    static let cellPadding: CGFloat = 10.0
    static let itemsPerRow = 3
    static let cellIdentifier = "ImageCollectionViewCell"
    static let footerIdentifier = "CustomFooterView"
    static let itemsPerPage = 25
    static let searchDefaultPlaceholder = "Search"
}


class MainViewController: UIViewController {
    fileprivate var photosDataSource: [Photo]? = []
    fileprivate var delegate: MainViewControllerProtocol? = nil
    fileprivate var itemsPerRow = MainViewControllerConstants.itemsPerRow
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchString: String? = nil
    fileprivate var isLoading: Bool = false
    fileprivate var totalCount: Int = 0
    fileprivate var isFulfillingSearchConditions: Bool{
        get{
            if let searchText = searchController.searchBar.text{
                searchString = searchText
                return true
            }else{
                return false
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = PixabayProvider()
        
//        searchController.searchResultsUpdater = self
        
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        self.navigationItem.titleView?.tintColor = .white
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    //MARK: - Get data from server
    fileprivate func search(forPage pageNumber: Int, completion:@escaping ([Photo]?)->Void){
        guard let searchString = searchString else{return}
        delegate?.searchPhotos(forSearchString: searchString, pageNumber: pageNumber, andItemsPerPage: MainViewControllerConstants.itemsPerPage, completion: {[weak self](results, total, error) in
            self?.isLoading = false
            DispatchQueue.main.async {
                if (error != nil || results?.count == 0) && self?.photosDataSource?.count == 0 {
                    self?.showError(error: error ?? "No Results Found")
                }else{
                    self?.totalCount = total ?? 0
                    completion(results)
                }
                self?.collectionView?.reloadData()
            }
        })
        isLoading = true
    }
    
    fileprivate func searchNextPage(){
        let currentPage = (photosDataSource?.count ?? 0)/MainViewControllerConstants.itemsPerPage
        search(forPage: currentPage+1, completion:{[weak self] (results) in
            guard let results = results else {return}
            self?.photosDataSource?.append(contentsOf: results)
        })
    }
    
    fileprivate func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { action in
            self.searchController.searchBar.placeholder = MainViewControllerConstants.searchDefaultPlaceholder
            self.searchString = nil
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource and Delegate implementation
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photosDataSource?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainViewControllerConstants.cellIdentifier, for: indexPath)
        
        let photo = photosDataSource![indexPath.item]
        (cell as! ImageCollectionViewCell).loadThumbImage(photo)
        
        let currentDataSourceSize = photosDataSource?.count ?? 0
        if (currentDataSourceSize - indexPath.row == (itemsPerRow)) && totalCount != self.photosDataSource?.count{
            searchNextPage()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MainViewControllerConstants.footerIdentifier, for: indexPath) as! CustomFooterView
        isLoading ? footerView.loader.startAnimating(): footerView.loader.stopAnimating()
        return footerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailVc = mainStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        detailVc.photosDataSource = self.photosDataSource
        detailVc.currentIndex = indexPath.item
        self.present(detailVc, animated: true, completion: nil)
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let paddingPerRow = MainViewControllerConstants.cellPadding * CGFloat(itemsPerRow - 1)
        let availableSpace = self.view.frame.width - paddingPerRow
        let dimensionOfEachItem = availableSpace/CGFloat(itemsPerRow)
        
        return CGSize(width: dimensionOfEachItem, height: dimensionOfEachItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MainViewControllerConstants.cellPadding
    }
}


extension MainViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isFulfillingSearchConditions{
            self.photosDataSource?.removeAll()
            search(forPage: 1, completion: {[weak self] results in
                guard let results = results else{return}
                self?.photosDataSource = results
            })
            searchController.isActive = false
            searchBar.placeholder = searchString
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.placeholder = MainViewControllerConstants.searchDefaultPlaceholder
    }
}


