//
//  HttpMethod.swift
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//


enum HttpMethod<Body> {
    case get
    case post(Body)
    case head
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .head: return "HEAD"
        }
    }
}
