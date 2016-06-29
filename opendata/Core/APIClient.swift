//
//  APIClient.swift
//  poi
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import MD5Digest
import SVProgressHUD

class APIClient: NSObject {
  static let sharedInstance = APIClient()
  
  func pinManager () -> Manager {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    let serverTrustPolicies: [String: ServerTrustPolicy] = [
      "data.taipei": .DisableEvaluation
    ]
    
    let manager = Alamofire.Manager(
      configuration: configuration,
      serverTrustPolicyManager:ServerTrustPolicyManager(policies: serverTrustPolicies))
    
    return manager
    
  }
  private func requestJSON(method: Alamofire.Method, url: String, parameter: AnyObject!, complete: ((JSON?, NSError?) -> Void)!) {
    let parseJSON = {
      (data: NSData) in
      
      let json = JSON(data:data)
      complete(json, nil)
    }
    
    let parseError = {
      (error: NSError) in
      
      complete(nil, error)
      
    }
    
    let manager = pinManager()
    switch method {
    case .GET:
      manager.request(.GET, url)
        .responseData { response in

          switch response.result {
          case .Success:
            parseJSON(response.result.value ?? "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
          case .Failure(let error):
            print(manager)
            parseError(error)
          }
      }
      break;
    case .POST:
      let request = NSMutableURLRequest(URL: NSURL(string:url)!)
      request.HTTPMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      do {
        request.HTTPBody  = try NSJSONSerialization.dataWithJSONObject(parameter!, options:[])
        
        
      } catch {
        print("JSON serialization failed:  \(error)")
      }
      manager.request(request)
        .responseData { response in
          print(response.request)
          print(response.response)
          print(response.result)
          
          switch response.result {
          case .Success:
            parseJSON(response.result.value ?? "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
          case .Failure(let error):
            print(manager)
            parseError(error)
          }
      }
      break
    default:
      break
    }
  }
  private func requestObject<T where T: Mappable>(type: T,method: Alamofire.Method, url: String, parameter: AnyObject?, complete: (([T]?, NSError?) -> Void)!) {

    let parseJSON = {
      (data: NSData) in
      
      let json = JSON(data:data)
      if let error = json["result"].error {
        complete(nil, error)
      }
      else{
        if let _ = json["result"]["results"].array {
          let rawString = json["result"]["results"].rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions.PrettyPrinted)
          let obj = Mapper<T>().mapArray(rawString!)
          complete(obj, nil)
          return
        }
        
        if let _ = json["result"]["results"].dictionary {
          let rawString = json["result"]["results"].rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions.PrettyPrinted)
          let obj = Mapper<T>().map(rawString)
          var buffer = [T]()
          buffer.append(obj!)
          complete(buffer, nil)
          return
        }
        
        complete(nil, nil)
      }
    }
    
    let parseError = {
      (error: NSError) in
      
      complete(nil, error)
      
    }
    
    let manager = pinManager()
    switch method {
    case .GET:
      manager.request(.GET, url)
        .responseData { response in
          print(response.request)
          print(response.response)
          print(response.result)
          
          switch response.result {
          case .Success:
            parseJSON(response.result.value ?? "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
          case .Failure(let error):
            print(manager)
            parseError(error)
          }
      }
    case .POST:
      let request = NSMutableURLRequest(URL: NSURL(string:url)!)
      request.HTTPMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      if let param = parameter {
        do {
          request.HTTPBody  = try NSJSONSerialization.dataWithJSONObject(param, options:[])
          
          
        } catch {
          print("JSON serialization failed:  \(error)")
        }
        
      }
      manager.request(request)
        .responseData { response in
          print(response.request)
          print(response.response)
          print(response.result)
          
          switch response.result {
          case .Success:
            parseJSON(response.result.value ?? "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
          case .Failure(let error):
            print(manager)
            parseError(error)
          }
      }
    default:
      break
    }
  }
  
  func requestTaipeiTravelPoi(offset: Int = 0, limit: Int = 10, complete: (([ResultEntity]?, NSError?) -> Void)!){
    let scope = "resourceAquire"
    let rid = "36847f3f-deff-4183-a5bb-800737591de5"
    let url = "http://data.taipei/opendata/datalist/apiAccess?scope=\(scope)&rid=\(rid)"
    
    let parseJSON = {
      (data: NSData) in
      
      let json = JSON(data:data)
      if let error = json["result"].error {
        complete(nil, error)
      }
      else{
        if let _ = json["result"]["results"].array {
          let rawString = json["result"]["results"].rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions.PrettyPrinted)
          let obj = Mapper<ResultEntity>().mapArray(rawString!)
          complete(obj, nil)
          return
        }
        
        if let _ = json["result"]["results"].dictionary {
          let rawString = json["result"]["results"].rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions.PrettyPrinted)
          let obj = Mapper<ResultEntity>().map(rawString)
          var buffer = [ResultEntity]()
          buffer.append(obj!)
          complete(buffer, nil)
          return
        }
        
        complete(nil, nil)
      }
    }

    let fileManager = NSFileManager.defaultManager()
    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    let pathComponent = (url as NSString).MD5Digest()
    
    let finalPath = directoryURL.URLByAppendingPathComponent(pathComponent)
    do {
      try fileManager.removeItemAtURL(finalPath)
    }
    catch _ {
      
    }

    SVProgressHUD.setFadeInAnimationDuration(0.1)
    SVProgressHUD.setFadeOutAnimationDuration(0.1)
    SVProgressHUD.setMinimumDismissTimeInterval(0.1)
    SVProgressHUD.showWithStatus("Downloading")
    Alamofire.download(.GET, url) {
      _ in
      return finalPath
      }.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        print(totalBytesRead)
        
        // This closure is NOT called on the main queue for performance
        // reasons. To update your ui, dispatch to the main queue.
        dispatch_async(dispatch_get_main_queue()) {
          print("Total bytes read on main queue: \(totalBytesRead)")
        }
      }
      .response { request, response, data, error in
        if let error = error {
          print("Failed with error: \(error)")
          SVProgressHUD.showErrorWithStatus(error.localizedDescription)
          complete(nil, error)
        } else {
          print("Downloaded file successfully")
          SVProgressHUD.showSuccessWithStatus("DONE")
          if let data = NSData(contentsOfURL: finalPath) {
            parseJSON(data)
          }
        }
    }

  }
}
