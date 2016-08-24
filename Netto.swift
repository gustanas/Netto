//
//  Netto.swift
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

protocol NettoActions {
    var setDefaultRequest: (NSMutableURLRequest -> Void)? { get }
}

extension Netto: NettoActions {
    var setDefaultRequest: (NSMutableURLRequest -> Void)? { return
        { request in
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
}

struct Netto {
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
