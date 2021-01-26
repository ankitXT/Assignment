//
//  NetworkManager.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//

import Foundation

typealias RequestCompletionHandler = (Data?, Error?) -> Void

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    private var session: URLSession? = nil
    
    private init(){
        session = URLSession(configuration: .default)
    }
    
    func request(withURL url: URL, completion: @escaping RequestCompletionHandler){
        let dataTask = session?.dataTask(with: url, completionHandler: {[weak self] (data, response, error) in
            if self?.isSuccessResponse(response, error) ?? false{
                completion(data, nil)
            }else{
                completion(nil, error)
            }
        })
        dataTask?.resume()
    }
    
    private func isSuccessResponse(_ response: URLResponse?,_ error: Error?)-> Bool{
        if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse{
            switch httpResponse.statusCode{
            case 200...202:
                return true
            default:
                return false
            }
        }else{
            return false
        }
    }
  
}
