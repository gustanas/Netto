//
//  WebService.swift
//  Ruby
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}


protocol Target {
    var baseURL: String { get }
    var path: String { get }
}

// Swift 3 lowerCase enum
enum Endpoint {
    case user
    case createUser
    case confirmationCode
}

extension Endpoint: Target {
    var baseURL: String {
        return "http://localhost:8080/"
    }
    
    var path: String {
        switch self {
        case .user:
            return "user-information"
        case .createUser:
            return "user-information"
        case .confirmationCode:
            return "confirmation-code"
        }
    }
}


struct Resource<A> {
    let endpoint: Endpoint
    let method: HttpMethod<AnyObject>
    let parser: AnyObject -> A?
}


class WebService {
    func loadResource<A>(resource: Resource<A>, requestPlugin: (NSMutableURLRequest -> Void)? = nil, completion: (A?,  NSURLResponse?, ErrorType?) -> ()) {
        let fullPath = "\(resource.endpoint.baseURL)\(resource.endpoint.path)"
        let url = NSURL(string: fullPath)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = resource.method.method
        if case let .post(json) = resource.method {
            let data = try? NSJSONSerialization.dataWithJSONObject(json, options: [])
            request.HTTPBody = data
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Customs parameters for request
        if let uRequestPlugin = requestPlugin {
            uRequestPlugin(request)
        }
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                completion(nil,response, error)
                return
            }

            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
          
            let parsedObjects = json.flatMap(resource.parser)
            completion(parsedObjects, response, error)
        }.resume()
    }
}
