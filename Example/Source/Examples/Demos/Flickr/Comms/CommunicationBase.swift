//
//  MockFlickerViewController.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

public enum HTTPMethod : Int {
    case GET = 1
    case POST = 2
    
    func stringValue() -> String {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        }
    }
}

public protocol Mappable {
    init(map: [NSString: NSObject])
    func jsonValue() -> [NSString : AnyObject]
}
extension Mappable {
    func jsonValue() -> [NSString : AnyObject] {
        return [NSString : AnyObject]()
    }
}
public class BaseRequest: Mappable {
    
    public var action: String
    public var controller: String
    public var headers: [String : String]?
    
    public var useURLPrams = false
    public var httpMethod = HTTPMethod.POST
    
    public init(controller: String, action: String) {
        self.action = action
        self.controller = controller
    }
    
    public required init(map: [NSString: NSObject]) {
        self.action = ""
        self.controller = ""
    }
    
    public func jsonValue() -> [NSString : AnyObject] {
        let map = [NSString : AnyObject]()
        return map
    }
}

public class CommunicationBase {
    
    var serviceEndPoint : String
    
    let queueName = "com.brickkit.communicationbase"
    
    public var urlArguments = false
    public var timeOutInterval : NSTimeInterval = 60
    public var qualityOfService : NSQualityOfService = .Default
    public var jsonReadingOptions : NSJSONReadingOptions = [.AllowFragments]
    public var sendStats = true
    public var printParams = true
    public var printRespose = true
    
    public class func communicationBase(withServiceEndPoint serviceEndPoint: String) -> CommunicationBase {
        return CommunicationBase(serviceEndPoint: serviceEndPoint)
    }
    
    public init(serviceEndPoint: String) {
        self.serviceEndPoint = serviceEndPoint
    }
    
    func buildQueryString(parameters: [String:String]) -> String {
        var urlVars:[String] = []
        
        for (k, value) in parameters {
            if let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        
        return urlVars.isEmpty ? "" : "?" + urlVars.joinWithSeparator("&")
    }
}

public extension CommunicationBase {
    
    public func jsonRequest<T: Mappable>(request: BaseRequest,
                            responseType toType: T.Type,
                            successHandler : ((T?) -> Void)? = nil,
                            errorHandler: ((NSError?) -> Void)? = nil) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            var jsonURL = self.serviceEndPoint.stringByAppendingString("\(request.controller)/\(request.action)")
            
            var webRequest = NSMutableURLRequest(URL: NSURL(string: jsonURL)!)
            
            if request.useURLPrams {
                jsonURL.appendContentsOf(self.buildQueryString(request.jsonValue() as! [String : String]))
                webRequest = NSMutableURLRequest(URL: NSURL(string: jsonURL)!)
            } else {
            
                let requestData = try? NSJSONSerialization.dataWithJSONObject(request.jsonValue() as NSDictionary, options: [.PrettyPrinted])
                webRequest.timeoutInterval = self.timeOutInterval
                webRequest.HTTPMethod = HTTPMethod.POST.stringValue()
                
                webRequest.setValue("\(requestData?.length ?? 0)", forHTTPHeaderField:"Content-Length")
                
                webRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
                
                webRequest.HTTPBody = requestData;

            }
            
            if let additionalHeaders = request.headers {
                for (key, value) in additionalHeaders {
                    webRequest.setValue(value, forHTTPHeaderField:key)
                }
            }
            
            let queue = NSOperationQueue()
            queue.name = self.queueName
            queue.qualityOfService = self.qualityOfService
            
            if self.printParams {
                    if webRequest.HTTPBody != nil {
                        print("\(NSString(data: webRequest.HTTPBody!, encoding: NSUTF8StringEncoding))")
                    } else {
                        print("no params")
                    }
                
                print(webRequest.allHTTPHeaderFields)
            }
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: queue)
            let task = session.dataTaskWithRequest(webRequest) { (data, response, error) in
                
                let httpResponse = response as? NSHTTPURLResponse
                let responseStatusCode = httpResponse?.statusCode ?? 400
                
                if self.printRespose {
                    if data != nil {
                        print("\(jsonURL):\(NSString(data: data!, encoding: NSUTF8StringEncoding))")
                    } else {
                        print("\(jsonURL): retured nil")
                    }
                }
                
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        errorHandler?(error as NSError?)
                    }
                    return
                }
                
                if responseStatusCode >= 300 && responseStatusCode != 500 {
                    let errorReturn = NSError(domain:"HTTP Error", code: responseStatusCode, userInfo: nil)
                     dispatch_async(dispatch_get_main_queue()) {
                        errorHandler?(errorReturn)
                    }
                    return
                }
                
                
                
                guard let returnData = data else {
                    successHandler?(nil)
                    return
                }
                
                var responseJSON : Any
                do {
                    responseJSON = try NSJSONSerialization.JSONObjectWithData(returnData, options: self.jsonReadingOptions)
                } catch let error as NSError {
                    errorHandler?(error)
                    return
                }
                
                if responseStatusCode >= 500 {
                    let errorReturn = NSError(domain: "Interanl Server Error", code: responseStatusCode, userInfo: responseJSON as? [NSString: AnyObject])
                     dispatch_async(dispatch_get_main_queue()) {
                        errorHandler?(errorReturn)
                    }
                    return
                }
                
                var value: T?
                
                if var responseDict = responseJSON as? [NSString: NSObject] {
                    if responseDict.keys.count == 1 && responseDict.keys.first == "d" {
                        if let newDict = responseDict["d"] as? [NSString: NSObject] {
                            responseDict = newDict
                        } else {
                            errorHandler?(NSError(domain:"Decode Error", code: -10, userInfo: nil))
                            return
                        }
                    }
                    
                    value = T(map: responseDict)
                    
                } else {
                    errorHandler?(NSError(domain:"Decode Error", code: -10, userInfo: nil))
                    return
                }
                
                
                 dispatch_async(dispatch_get_main_queue()) {
                    successHandler?(value)
                }
            }
            task.resume()
        }
    }

    public func jsonRequestAsyc<T: Mappable>(request: BaseRequest,
                                response: T.Type,
                                successHandler: ((T?) -> Void)? = nil,
                                errorHandler: ((NSError?) -> Void)? = nil) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let jsonURL = self.serviceEndPoint.stringByAppendingString("\(request.controller)/\(request.action)")
            
            let requestData = try? NSJSONSerialization.dataWithJSONObject(request.jsonValue() as NSDictionary, options: [.PrettyPrinted])
            
            let webRequest = NSMutableURLRequest(URL: NSURL(string: jsonURL)!)
            
            webRequest.timeoutInterval = self.timeOutInterval
            webRequest.HTTPMethod = HTTPMethod.POST.stringValue()
            
            webRequest.setValue("\(requestData?.length ?? 0)", forHTTPHeaderField:"Content-Length")
            
            webRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            
            webRequest.HTTPBody = requestData;
            
            if let additionalHeaders = request.headers {
                for (key, value) in additionalHeaders {
                    webRequest.setValue(value, forHTTPHeaderField:key)
                }
            }
            
            let queue = NSOperationQueue()
            queue.name = self.queueName
            queue.qualityOfService = self.qualityOfService
            
            if self.printParams {
                if webRequest.HTTPBody != nil {
                    print("\(NSString(data: webRequest.HTTPBody!, encoding: NSUTF8StringEncoding))")
                } else {
                    print("no params")
                }
                
                print(webRequest.allHTTPHeaderFields)
            }
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: queue)
            let task = session.dataTaskWithRequest(webRequest) { (data, response, error) in
                
                let httpResponse = response as? NSHTTPURLResponse
                let responseStatusCode = httpResponse?.statusCode ?? 400
                
                if self.printRespose {
                    if data != nil {
                        print("\(jsonURL):\(NSString(data: data!, encoding: NSUTF8StringEncoding))")
                    } else {
                        print("\(jsonURL): retured nil")
                    }
                }
                
                if error != nil {
                    errorHandler?(error as NSError?)
                    return
                }
                
                if responseStatusCode >= 300 && responseStatusCode != 500 {
                    let errorReturn = NSError(domain:"HTTP Error", code: responseStatusCode, userInfo: nil)
                    errorHandler?(errorReturn)
                    return
                }
                
                
                
                guard let returnData = data else {
                    successHandler?(nil)
                    return
                }
                
                var responseJSON : Any
                do {
                    responseJSON = try NSJSONSerialization.JSONObjectWithData(returnData, options: self.jsonReadingOptions)
                } catch let error as NSError {
                    errorHandler?(error)
                    return
                }
                
                if responseStatusCode >= 500 {
                    let errorReturn = NSError(domain: "Interanl Server Error", code: responseStatusCode, userInfo: responseJSON as? [NSString: AnyObject])
                    errorHandler?(errorReturn)
                    return
                }
                
                var value: T?
                
                if var responseDict = responseJSON as? [NSString: NSObject] {
                    if responseDict.keys.count == 1 && responseDict.keys.first == "d" {
                        if let newDict = responseDict["d"] as? [NSString: NSObject] {
                            responseDict = newDict
                        } else {
                            errorHandler?(NSError(domain:"Decode Error", code: -10, userInfo: nil))
                            return
                        }
                    }
                    
                    value = T(map: responseDict)
                    
                } else {
                    errorHandler?(NSError(domain:"Decode Error", code: -10, userInfo: nil))
                    return
                }
                
                successHandler?(value)
            }
            task.resume()
        }
    }

}
