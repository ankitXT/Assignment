//
//  Suggestions.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//

import Foundation

class Suggestions {
    static let sharedInstance = Suggestions()
    
    private let suggestionsKey = "suggestions"
    
    var recentlySearched: [String] {
        get{
            return UserDefaults.standard.object(forKey: suggestionsKey) as? [String] ?? []
        }
        set{
            UserDefaults.standard.set(Array(newValue.prefix(10)), forKey: suggestionsKey)
        }
    }

}
