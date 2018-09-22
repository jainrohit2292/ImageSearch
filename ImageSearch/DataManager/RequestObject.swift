//
//  RequestObject.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit
import Alamofire

class RequestObject: NSObject {
    var baseURL : String?                               //Base URL For Request
    var apiPath : String?                               //API to call
    var params : [String : Any]?                        //Request parameters
    var requestType : HTTPMethod = .get                 //HTTP Request Type i.e. GET, POST
    var headers : [String : Any]?                       //Request Headers
    var multiPartBody : MultipartFormData?              //For Sending Data and image in Form
    
    override init() {
        super.init()
    }
    
    var apiURL: String{
        return self.baseURL! + (self.apiPath != nil ? self.apiPath! : "")
    }
}
