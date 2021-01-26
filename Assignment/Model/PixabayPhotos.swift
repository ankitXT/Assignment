//
//  PixabayPhotos.swift
//  Assignment
//
//  Created by Ankit Chhabra on 26/01/21.
//  Copyright © 2021 admin. All rights reserved.
//

import Foundation

struct PixabayPhotos: Codable {
    
    var total : Int?
    var totalHits : Int?
    var hits : [Photo]?
    
}

struct Photo: Codable {
    let previewURL : String?
    let largeImageURL : String?
    let id : Int?

}

