//
//  ResponseObject.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit
import Alamofire

class ResponseObject: NSObject {
    var responseObject : AnyObject?
    var rawData : Data?
    var httpResponse : HTTPURLResponse?
    var apiUrl: String!
    
    private override init() {
        super.init()
    }
    
    init(with response:DataResponse<Any>) {
        super.init()
        self.rawData = response.data
        self.responseObject = response.result.value as AnyObject?
        self.httpResponse = response.response
    }
    
    init(with response:DataResponse<String>) {
        super.init()
        self.rawData = response.data
        self.responseObject = response.result.value as AnyObject?
        if let res = response.result.value{
            self.responseObject = self.jsonStringToDictionary(jsonText: res) as AnyObject?
        }
        self.httpResponse = response.response
    }
    
    func jsonStringToDictionary(jsonText:String) -> [String:Any]?{
        var dictonary:[String:Any]?
        
        if let data = jsonText.data(using: String.Encoding.utf8) {
            
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return dictonary
    }
}

class ErrorResponse: NSObject{
    var statusCode: Int = 0
    var message: String?
    var error:Error?
    override init() {
        super.init()
    }
}
