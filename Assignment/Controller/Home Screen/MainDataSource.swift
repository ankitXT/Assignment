//
//  MainDataSource.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//

import Foundation
import UIKit

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

//MARK: - Table View Delegate and Datasource for Suggestion list
extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.suggestions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell")!
        cell.textLabel?.text = suggestions?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchBar.text = suggestions?[indexPath.row]
        searchBarSearchButtonClicked(self.searchBar)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recently Searched items"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
}
