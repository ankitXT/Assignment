//
//  PixabayProvider.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//


import Foundation

private struct PixabayProviderConstants{
    static let apiKey = "20028025-540f53b7fc70a1460cd78e158"
    static let pixabayAPIBaseURL = "https://pixabay.com/api/"

    struct Messages {
        static let searchURLCreationFailed = "Failed to create search URL."
        static let parsingFailed = "Failed to parse result."
    }
}


protocol MainViewControllerProtocol {
    func searchPhotos(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int, completion: @escaping ([Photo]?, Int?, String?)-> Void)
}

class PixabayProvider: MainViewControllerProtocol{
    
    func searchPhotos(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int, completion: @escaping ([Photo]?, Int?, String?)-> Void){
        guard let pixabaySearchURL = searchURL(forSearchString: searchString, pageNumber: pageNumber, andItemsPerPage: itemsPerPage) else{
            completion(nil, 0, PixabayProviderConstants.Messages.searchURLCreationFailed)
            return
        }
        
        NetworkManager.shared.request(withURL: pixabaySearchURL, completion:{[weak self] (data, error) in
            if let _ = error {
                completion(nil, 0, error.debugDescription)
            }else{
                if let results = self?.parseSearchResult(data){
                    completion(results.hits, results.total, nil)
                }else{
                    completion(nil, 0, PixabayProviderConstants.Messages.parsingFailed)
                }
            }
        })
    }
    
    private func searchURL(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int) -> URL?{
        
        guard let escapedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else { return nil }
        
        let URLString = "\(PixabayProviderConstants.pixabayAPIBaseURL)?key=\(PixabayProviderConstants.apiKey)&q=\(escapedSearchString)&image_type=photo&per_page=\(itemsPerPage)&page=\(pageNumber)"
        
        guard let url = URL(string: URLString) else { return nil }
        
        return url
    }
    
    private func parseSearchResult(_ data: Data?) -> PixabayPhotos? {
        guard let data = data else{return nil}
        
        do {
            let pixabayPhotos = try JSONDecoder().decode(PixabayPhotos.self, from: data)

            return pixabayPhotos
        } catch _ {
            print(PixabayProviderConstants.Messages.parsingFailed)
        }
        return nil
    }
}
