# Netto - ネット

A tiny protocol-oriented network layer written in Swift

## Endpoint

Define your different endpoints using an *enum*:

``` swift
enum Endpoint {
    case user
    case confirmationCode
}
```

And make that endpoint conform to the *Path* protocol:

``` swift
protocol Path {
    var baseURL: String { get }
    var path: String { get }
}

extension Endpoint: Path {
    var baseURL: String {
        return "http://localhost:8080/"
    }
    
    var path: String {
        switch self {
        case .user:
            return "user-information"
        case .confirmationCode:
            return "confirmation-code"
        }
    }
}
```

## Create the *resources* you want to load

``` swift
struct Resource<A> {
  let endpoint: Endpoint
  let method: HttpMethod<AnyObject>
  let parser: AnyObject -> A?
}
```

A *Resource<A>* holds the endpoint you will query, the http method (get, post, etc) and a parser closure that parse JSON to an object of type *A*.

## Example of a call

``` swift
struct User {
    let username: String
}

extension User {
    init?(dictionary: [String: AnyObject]) {
        guard let username = dictionary["username"] as? String else { return nil }
        self.username = username
    }
}

func queryUserEndpoint() {
  let parameters = ["username": "test"]
  let userResource = Resource<User>(endpoint: Endpoint.user, method: .post(parameters)) { json in
    guard let dictionary = json as? [String: AnyObject] else { return nil }
    return User.init(dictionary: dictionary)
  }
  
  let ws = Netto()

  ws.loadResource(userResource) { [weak self] (user, response, error) in
    // handle response
  }

}
```

## Custom actions

If you want to set some default behaviour to your requests, use the *NettoActions* protocol:

``` swift
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
```

Other actions will be added in the future, like *willSendRequest*, *didReceiveResponse*, etc.

Finally, you can also define custom behaviour only on specific requests, for example: 

``` swift
...
let requestClosure: NSMutableURLRequest -> Void = { request in
    guard let token = KeychainWrapper.stringForKey("bearer") else { return }
    request.addValue(token, forHTTPHeaderField: "Authorization")
}
        
ws.loadResource(resource, requestPlugin: requestClosure) { users, response, error in
    // handle response
}
```



