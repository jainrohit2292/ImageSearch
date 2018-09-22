//
//  ImageListDataModel.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit

class ImageListDataModel: NSObject, NSCoding {
    
    var byteSize: Int?
    var contextLink: String?
    var height: Int?
    var thumbnailHeight: Int?
    var thumbnailLink: String?
    var thumbnailWidth: Int?
    var width : Int?

    
    init(With dictionary:[String:Any]?) {
        super.init()
        if let dict = dictionary{
            if let nodeValue = dict["byteSize"] as? Int{
                byteSize = nodeValue
            }
            if let nodeValue = dict["contextLink"] as? String{
                contextLink = nodeValue
            }
            if let nodeValue = dict["height"] as? Int{
                height = nodeValue
            }
            if let nodeValue = dict["thumbnailHeight"] as? Int{
                thumbnailHeight = nodeValue
            }
            if let nodeValue = dict["thumbnailLink"] as? String{
                thumbnailLink = nodeValue
            }
            if let nodeValue = dict["thumbnailWidth"] as? Int{
                thumbnailWidth = nodeValue
            }
            if let nodeValue = dict["width"] as? Int{
                width = nodeValue
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        byteSize = aDecoder.decodeObject(forKey: "byteSize") as? Int
        contextLink = aDecoder.decodeObject(forKey: "contextLink") as? String
        height = aDecoder.decodeObject(forKey: "height") as? Int
        thumbnailHeight = aDecoder.decodeObject(forKey: "thumbnailHeight") as? Int
        thumbnailLink = aDecoder.decodeObject(forKey: "thumbnailLink") as? String
        thumbnailWidth = aDecoder.decodeObject(forKey: "thumbnailWidth") as? Int
        width = aDecoder.decodeObject(forKey: "width") as? Int
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(byteSize, forKey: "byteSize")
        aCoder.encode(contextLink, forKey: "contextLink")
        aCoder.encode(height, forKey: "height")
        aCoder.encode(thumbnailHeight, forKey: "thumbnailHeight")
        aCoder.encode(thumbnailLink, forKey: "thumbnailLink")
        aCoder.encode(thumbnailWidth, forKey: "thumbnailWidth")
        aCoder.encode(width, forKey: "width")
    }
}
