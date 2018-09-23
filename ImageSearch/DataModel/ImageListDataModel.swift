//
//  ImageListDataModel.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import Foundation
import RealmSwift

class ImageListDataModel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var contextLink: String?
    @objc dynamic var thumbnailLink: String?
    @objc dynamic var searchTerm: String?

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func IncrementaID() -> Int{
        let realm = try! Realm()
        if let retNext = realm.objects(ImageListDataModel.self).sorted(byKeyPath: "id").last?.id {
            return retNext + 1
        }else{
            return 1
        }
    }
    
    convenience init(With dictionary:[String:Any]?, searchText: String) {
        self.init()
        self.id = self.IncrementaID()
        searchTerm = searchText
        if let dict = dictionary{
            if let nodeValue = dict["contextLink"] as? String{
                contextLink = nodeValue
            }
            if let nodeValue = dict["thumbnailLink"] as? String{
                thumbnailLink = nodeValue
            }
        }
    }
}
