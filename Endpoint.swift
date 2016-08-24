//
//  Endpoint.swift
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//

// Swift 3 lowerCase enum
enum Endpoint {
    case user
    case createUser
    case confirmationCode
}

extension Endpoint: Target {
    var baseURL: String {
        return "http://localhost:8080/"
        //return "https://project-ruby.herokuapp.com/"
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
