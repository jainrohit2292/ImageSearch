//
//  ImageNetworkWrapper.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ImageNetworkWrapper: NSObject {
    static let sharedInstance = ImageNetworkWrapper()
    var realm = try! Realm()
    
    private override init() {
        super.init()
        realm.autorefresh = true
    }
    
    func getImageList(text:String,startIndex:Int,success:@escaping ([ImageListDataModel]) -> Void, failure:@escaping (ErrorResponse) -> Void){
        let requestObject = RequestObject()
        requestObject.baseURL = APIConstants.URL.googleImageUrl
        requestObject.apiPath = "key=\(APIConstants.Key.api_key)&cx=\(APIConstants.Key.cx_key)&q=\(text)&searchType=image&imgSize=medium&alt=json&num=10&start=\(startIndex)"
        requestObject.requestType = .get
        
        KPNetworkManager.getDataFor(Request: requestObject, success: {object in
            if let obj = object.responseObject as? [String:Any]{
                if let imgList = obj["items"] as? [Any]{
                    print(imgList)
                    var imageModel:[ImageListDataModel] = []
                    
                    let uiRealm = try! Realm()
                    try! uiRealm.write {
                        for data in imgList {
                            if let a = data as? [String:Any]{
                                let model = ImageListDataModel(With: a["image"] as? [String:Any], searchText: text.lowercased())
                                imageModel.append(model)
                                uiRealm.add(model)
                            }
                        }
                    }
                    success(imageModel)
                }
            }
        }, failure: {error in
            print(error)
            failure(error)
        })
    }
}
