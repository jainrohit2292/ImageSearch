//
//  NetworkManager.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit
import Alamofire

class KPNetworkManager: NSObject {
    static let sharedInstance = KPNetworkManager()
    
    private override init() {
        super.init()
    }
    
    /** Data Request with Block CallBack and Class Method*/
    class func getDataFor(Request dataRequest:RequestObject?, success:@escaping (ResponseObject) -> Void, failure:@escaping (ErrorResponse) -> Void){
        let url : String = dataRequest!.apiURL
        var requestType : HTTPMethod = .get
        var params : [String:Any]?
        var headers : [String:Any]?
        
        if let param = dataRequest?.params{
            params = param
        }else{
            params = nil
        }
        
        if let type = dataRequest?.requestType{
            if (type == .get){
                requestType = .get
                request(url, method: requestType, parameters: params, encoding: URLEncoding.default, headers: headers as! HTTPHeaders?).responseJSON{response in
                    if response.result.isSuccess{
                        if let httpResponse = response.response{
                            if httpResponse.statusCode < 300{
                                let resObj = ResponseObject(with: response)
                                resObj.apiUrl = url
                                success(resObj)
                            }else{
                                let errorModel = ErrorResponse()
                                errorModel.error = response.error
                                errorModel.message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                                errorModel.statusCode = httpResponse.statusCode
                                failure(errorModel)
                            }
                        }
                    }else if response.result.isFailure{
                        var code = 0
                        if let error = response.error as NSError?{
                            code = error.code
                        }
                        let errorModel = ErrorResponse()
                        errorModel.error = response.error
                        errorModel.message = response.error?.localizedDescription
                        errorModel.statusCode = code
                        failure(errorModel)
                    }
                }
            }else if (type == .post){
                requestType = .post
                
                //                request(url, method: requestType, parameters: params, encoding: JSONEncoding.default, headers: headers as! HTTPHeaders?).response(completionHandler: {response in
                //
                //                    print(response)
                //                })
                
                
                request(url, method: requestType, parameters: params, encoding: JSONEncoding.default, headers: headers as! HTTPHeaders?).responseString(completionHandler: {response in
                    
                    if response.result.isSuccess{
                        if let httpResponse = response.response{
                            if httpResponse.statusCode < 300{
                                let resObj = ResponseObject(with: response)
                                resObj.apiUrl = url
                                success(resObj)
                            }else{
                                let errorModel = ErrorResponse()
                                errorModel.error = response.error
                                errorModel.message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                                errorModel.statusCode = httpResponse.statusCode
                                failure(errorModel)
                            }
                        }
                    }else if response.result.isFailure{
                        var code = 0
                        if let error = response.error as NSError?{
                            code = error.code
                        }
                        let errorModel = ErrorResponse()
                        errorModel.error = response.error
                        errorModel.message = response.error?.localizedDescription
                        errorModel.statusCode = code
                        failure(errorModel)
                    }
                })
                //                request(url, method: requestType, parameters: params, encoding: JSONEncoding.default, headers: headers as! HTTPHeaders?).responseJSON{response in
                //
                //                    if response.result.isSuccess{
                //                        if let httpResponse = response.response{
                //                            if httpResponse.statusCode < 300{
                //                                let resObj = KPResponseObject(with: response)
                //                                resObj.apiUrl = url
                //                                success(resObj)
                //                            }else{
                //                                let errorModel = KPErrorResponse()
                //                                errorModel.error = response.error
                //                                errorModel.message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                //                                errorModel.statusCode = httpResponse.statusCode
                //                                failure(errorModel)
                //                            }
                //                        }
                //                    }else if response.result.isFailure{
                //                        var code = 0
                //                        if let error = response.error as NSError?{
                //                            code = error.code
                //                        }
                //                        let errorModel = KPErrorResponse()
                //                        errorModel.error = response.error
                //                        errorModel.message = response.error?.localizedDescription
                //                        errorModel.statusCode = code
                //                        failure(errorModel)
                //                    }
                //                }
            }
        }
    }
    
    func uploadImage(Request dataRequest:RequestObject?, success:@escaping (ResponseObject) -> Void, failure:@escaping (ErrorResponse) -> Void){
        let url : String = dataRequest!.apiURL
        let requestType : HTTPMethod = (dataRequest?.requestType)!
        var params : [String:Any] = [String:Any]()
        var headers : [String:Any]?
        
        if let param = dataRequest?.params{
            params = param
        }
        
        upload(multipartFormData: {multiformData in
            for kv in params{
                multiformData.append(kv.value as! Data, withName: kv.key, fileName: "image.jpeg", mimeType: "image/jpeg")
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: requestType, headers: headers as? HTTPHeaders, encodingCompletion: {encodingResult in
            switch encodingResult{
            case .failure(let err):
                print(err)
                break
            case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                request.responseJSON(completionHandler: {response in
                    if response.result.isSuccess{
                        if let httpResponse = response.response{
                            if httpResponse.statusCode < 300{
                                let resObj = ResponseObject(with: response)
                                resObj.apiUrl = url
                                success(resObj)
                            }else{
                                let errorModel = ErrorResponse()
                                errorModel.error = response.error
                                errorModel.message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                                errorModel.statusCode = httpResponse.statusCode
                                failure(errorModel)
                            }
                        }
                    }else if response.result.isFailure{
                        var code = 0
                        if let error = response.error as NSError?{
                            code = error.code
                        }
                        let errorModel = ErrorResponse()
                        errorModel.error = response.error
                        errorModel.message = response.error?.localizedDescription
                        errorModel.statusCode = code
                        failure(errorModel)
                    }
                })
                break
            }
        })
    }
    
    /** Download and Cache Image in File Directory */
    func downloadImage(fromURL url:String,success:@escaping (UIImage, String) -> Void) {
        
        let urlParts = url.components(separatedBy: "/")
        let fileName = urlParts.last
        
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = directoryURLs.appendingPathComponent(fileName!).path
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: fileUrl){
            let image = UIImage.init(contentsOfFile: fileUrl)
            if let img = image{
                success(img, url)
            }
        }else{
            let des = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            download(url, to: des).responseData(completionHandler: {response in
                if let path = response.destinationURL?.path{
                    let image = UIImage.init(contentsOfFile: path)
                    if let img = image{
                        success(img, url)
                    }
                }
            })
        }
    }
}
