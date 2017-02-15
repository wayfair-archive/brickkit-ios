//
//  MockFlickerViewController.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

public enum HTTPMethod : String {
    case GET = "GET"
    case POST = "POST"
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

extension URL {
    func URLByAppendingQueryParameters(parameters: [String:String]) -> URL? {
        if parameters.count == 0 {
            return self
        }
        
        var urlVars = [String]()
        
        for (k, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        
        if urlVars.isEmpty {
            return self
        }

        let stringOperator = self.query != nil ? "&" : "?"
        return URL(string: "\(self.absoluteString)\(stringOperator)\(urlVars.joined(separator: "&"))")
    }
}

public class CommunicationBase {
    
    var serviceEndPoint : NSURL
    
    let queueName = "com.brickkit.communicationbase"
    
    public var urlArguments = false
    public var timeOutInterval : TimeInterval = 60
    public var qualityOfService : QualityOfService = .default
    public var jsonReadingOptions : JSONSerialization.ReadingOptions = [.allowFragments]
    public var sendStats = true
    public var printParams = true
    public var printRespose = true
    
    public class func communicationBase(withServiceEndPoint serviceEndPoint: NSURL) -> CommunicationBase {
        return CommunicationBase(serviceEndPoint: serviceEndPoint)
    }
    
    public init(serviceEndPoint: NSURL) {
        self.serviceEndPoint = serviceEndPoint
    }
}

public extension CommunicationBase {
    
    public func jsonRequest<T: Mappable>(request: BaseRequest,
                            responseType toType: T.Type,
                            successHandler : ((T?) -> Void)? = nil,
                            errorHandler: ((NSError?) -> Void)? = nil) {
        
        
        DispatchQueue.global(qos: .utility).async {
            let jsonURL = self.serviceEndPoint.appendingPathComponent("\(request.controller)/\(request.action)")
            
            var webRequest = NSMutableURLRequest(url: jsonURL!)
            
            if request.useURLPrams {
                let newURL = jsonURL?.URLByAppendingQueryParameters(parameters: request.jsonValue() as! [String : String])
                webRequest = NSMutableURLRequest(url: newURL!)
            } else {
            
                let requestData = try? JSONSerialization.data(withJSONObject: request.jsonValue() as NSDictionary, options: [.prettyPrinted])
                webRequest.timeoutInterval = self.timeOutInterval
                webRequest.httpMethod = HTTPMethod.POST.rawValue
                
                webRequest.setValue("\(requestData?.count ?? 0)", forHTTPHeaderField:"Content-Length")
                
                webRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
                
                webRequest.httpBody = requestData;

            }
            
            if let additionalHeaders = request.headers {
                for (key, value) in additionalHeaders {
                    webRequest.setValue(value, forHTTPHeaderField:key)
                }
            }
            
            let queue = OperationQueue()
            queue.name = self.queueName
            queue.qualityOfService = self.qualityOfService
            
            if self.printParams {
                    if webRequest.httpBody != nil {
                        print("\(NSString(data: webRequest.httpBody!, encoding: String.Encoding.utf8.rawValue))")
                    } else {
                        print("no params")
                    }
                
                print(webRequest.allHTTPHeaderFields)
            }
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
            let task = session.dataTask(with: webRequest as URLRequest) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let responseStatusCode = httpResponse?.statusCode ?? 400
                
                if self.printRespose {
                    if data != nil {
                        print("\(jsonURL):\(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))")
                    } else {
                        print("\(jsonURL): retured nil")
                    }
                }
                
                if error != nil {
                    DispatchQueue.main.async {
                        errorHandler?(error as NSError?)
                    }
                    return
                }
                
                if responseStatusCode >= 300 && responseStatusCode != 500 {
                    let errorReturn = NSError(domain:"HTTP Error", code: responseStatusCode, userInfo: nil)
                    DispatchQueue.main.async {
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
                    responseJSON = try JSONSerialization.jsonObject(with: returnData, options: self.jsonReadingOptions)
                } catch let error as NSError {
                    errorHandler?(error)
                    return
                }
                
                if responseStatusCode >= 500 {
                    let errorReturn = NSError(domain: "Interanl Server Error", code: responseStatusCode, userInfo: responseJSON as? [NSString: AnyObject])
                    DispatchQueue.main.async {
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
                
                
                DispatchQueue.main.async {
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
        
        DispatchQueue.global(qos: .utility).async {
            let jsonURL = self.serviceEndPoint.appendingPathComponent("\(request.controller)/\(request.action)")
            
            let requestData = try? JSONSerialization.data(withJSONObject: request.jsonValue() as NSDictionary, options: [.prettyPrinted])
            
            let webRequest = NSMutableURLRequest(url: jsonURL!)
            
            webRequest.timeoutInterval = self.timeOutInterval
            webRequest.httpMethod = HTTPMethod.POST.rawValue
            
            webRequest.setValue("\(requestData?.count ?? 0)", forHTTPHeaderField:"Content-Length")
            
            webRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            
            webRequest.httpBody = requestData;
            
            if let additionalHeaders = request.headers {
                for (key, value) in additionalHeaders {
                    webRequest.setValue(value, forHTTPHeaderField:key)
                }
            }
            
            let queue = OperationQueue()
            queue.name = self.queueName
            queue.qualityOfService = self.qualityOfService
            
            if self.printParams {
                if webRequest.httpBody != nil {
                    print("\(NSString(data: webRequest.httpBody!, encoding: String.Encoding.utf8.rawValue))")
                } else {
                    print("no params")
                }
                
                print(webRequest.allHTTPHeaderFields)
            }
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
            let task = session.dataTask(with: webRequest as URLRequest) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let responseStatusCode = httpResponse?.statusCode ?? 400
                
                if self.printRespose {
                    if data != nil {
                        print("\(jsonURL):\(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))")
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
                    responseJSON = try JSONSerialization.jsonObject(with: returnData, options: self.jsonReadingOptions)
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
