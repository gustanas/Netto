//
//  Resource.swift
//
//  Created by Gustavo Nascimento on 8/15/16.
//  Copyright © 2016. All rights reserved.
//

struct Resource<A> {
    let endpoint: Endpoint
    let method: HttpMethod<AnyObject>
    let parser: AnyObject -> A?
}