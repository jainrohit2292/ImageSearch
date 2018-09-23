//
//  DatabaseManager.swift
//  ImageSearch
//
//  Created by Rohit Jain on 23/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class DatabaseManager {
    
    static let sharedInstance = DatabaseManager()
    var realm = try! Realm()
    init() {
        realm.autorefresh = true
    }
    
    func getDataFromRealm(searchItem: String) -> [ImageListDataModel] {
        let realm = try! Realm()
        let imageModel = realm.objects(ImageListDataModel.self).filter("searchTerm == %@", searchItem.lowercased())
        return Array(imageModel)
    }
    
}

