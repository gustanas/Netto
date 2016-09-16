//
//  Netto.swift
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

protocol NettoActions {
    var setDefaultRequest: ((inout URLRequest) -> Void)? { get }
}

extension Netto: NettoActions {
    var setDefaultRequest: ((inout URLRequest) -> Void)? { return
        { request in
            
            if let token = KeychainWrapper.stringForKey("bearer") {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
}

struct Netto {
    
    func loadResource<A>(_ resource: Resource<A>, requestPlugin: ((URLRequest) -> Void)? = nil, completion: @escaping (A?,  URLResponse?, Error?) -> ()) {
        
        let fullPath = "\(resource.endpoint.baseURL)\(resource.endpoint.path)"
        guard let url = URL(string: fullPath) else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = resource.method.method
        if case let .post(json) = resource.method {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = data
        }
        
        
        setDefaultRequest?(&request)
        
        // Customs parameters for request
        requestPlugin?(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil,response, error)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data, options: [])
          
            let parsedObjects = json.flatMap(resource.parser)
            completion(parsedObjects, response, error)
        }.resume()
    }
}
