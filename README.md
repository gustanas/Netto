# Netto

A tiny protocol-oriented network layer written in Swift

## Endpoint

Define your different endpoints using an *enum*:

``` swift
enum Endpoint {
    case user
    case createUser
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
        case .createUser:
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
  let userResource = Resource<User>(endpoint: Endpoint.createUser, method: .post(parameters)) { json in
    guard let dictionary = json as? [String: AnyObject] else { return nil }
    return User.init(dictionary: dictionary)
  }
  
  let ws = Netto()

  ws.loadResource(userResource) { [weak self] (user, response, error) in
    // handle response
  }

}
```




