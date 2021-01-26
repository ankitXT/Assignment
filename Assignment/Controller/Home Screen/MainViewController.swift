//
//  MainViewController.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit
import Foundation

struct MainViewControllerConstants{
    static let cellPadding: CGFloat = 10.0
    static let itemsPerRow = 3
    static let cellIdentifier = "ImageCollectionViewCell"
    static let footerIdentifier = "CustomFooterView"
    static let itemsPerPage = 25
    static let searchDefaultPlaceholder = "Search"
}


class MainViewController: UIViewController {

    //MARK: - Properties

    var photosDataSource: [Photo]? = []
    var delegate: MainViewControllerProtocol? = nil
    var itemsPerRow = MainViewControllerConstants.itemsPerRow
    let searchBar = UISearchBar()
    var searchString: String? = nil
    var isLoading: Bool = false
    var totalCount: Int = 0
    var isFulfillingSearchConditions: Bool{
        get{
            if let searchText = searchBar.text{
                searchString = searchText
                return true
            }else{
                return false
            }
        }
    }
    
    var suggestions: [String]? = []
    
    //MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var suggestionTableView: UITableView!

    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = PixabayProvider()
        
//        searchController.searchResultsUpdater = self
        
        searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchBar
        self.navigationItem.titleView?.tintColor = .white
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
                    Suggestions.sharedInstance.addNewSuggestion(searchString)
                    completion(results)
                }
                self?.collectionView?.reloadData()
            }
        })
        isLoading = true
    }
    
    func searchNextPage(){
        let currentPage = (photosDataSource?.count ?? 0)/MainViewControllerConstants.itemsPerPage
        search(forPage: currentPage+1, completion:{[weak self] (results) in
            guard let results = results else {return}
            self?.photosDataSource?.append(contentsOf: results)
        })
    }
    
    fileprivate func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { action in
            self.searchBar.placeholder = MainViewControllerConstants.searchDefaultPlaceholder
            self.searchString = nil
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Search Bar Delegates
extension MainViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isFulfillingSearchConditions{
            self.photosDataSource?.removeAll()
            search(forPage: 1, completion: {[weak self] results in
                guard let results = results else{return}
                self?.photosDataSource = results
            })
            searchBar.resignFirstResponder()
            searchBar.placeholder = searchString
            searchBar.text = ""
            self.suggestionTableView.isHidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.placeholder = MainViewControllerConstants.searchDefaultPlaceholder
        suggestions = Suggestions.sharedInstance.recentlySearched
        if suggestions?.count == 0 {
            self.suggestionTableView.isHidden = true
        }else {
            self.suggestionTableView.isHidden = false
            self.suggestionTableView.reloadData()
        }
    }
}


