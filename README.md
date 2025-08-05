# swift-urlrequest-handler

A comprehensive URLRequest handling system for Swift with structured error handling, envelope/direct response decoding, and dependency injection support.

![Version](https://img.shields.io/badge/version-0.0.1-green.svg)
![Swift](https://img.shields.io/badge/swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)

## Features

* **Structured URLRequest handling**: Type-safe request handler with automatic response decoding
* **Envelope pattern support**: Automatically handles both envelope-wrapped and direct JSON responses
* **Comprehensive error handling**: Detailed error types with context for debugging
* **Privacy-conscious logging**: Automatic sanitization of sensitive headers (authorization, tokens)
* **Dependency injection**: Built-in support for swift-dependencies
* **Configurable JSON decoding**: Customizable decoder with sensible defaults
* **Test support**: Debug mode for testing with enhanced logging
* **URLSession abstraction**: Testable URLSession dependency

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-urlrequest-handler", from: "0.0.1")
]
```

Then add `URLRequestHandler` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "URLRequestHandler", package: "swift-urlrequest-handler")
        ]
    )
]
```

## Usage

### Basic Request Handling

```swift
import URLRequestHandler
import Dependencies

struct MyAPI {
    @Dependency(\.defaultRequestHandler) var requestHandler
    
    func fetchUser(id: String) async throws -> User {
        let request = URLRequest(url: URL(string: "https://api.example.com/users/\(id)")!)
        
        return try await requestHandler(
            for: request,
            decodingTo: User.self
        )
    }
}

struct User: Decodable {
    let id: String
    let name: String
    let email: String
}
```

### Envelope Response Pattern

The handler automatically attempts to decode responses as envelope-wrapped first, then falls back to direct decoding:

```swift
// Handles this envelope response:
// {
//   "success": true,
//   "data": { "id": "123", "name": "John" },
//   "message": "User fetched successfully",
//   "timestamp": "2024-01-01T00:00:00Z"
// }

// And also handles direct response:
// { "id": "123", "name": "John" }

let user: User = try await requestHandler(
    for: request,
    decodingTo: User.self
)
```

### Custom JSON Decoder

```swift
var handler = URLRequest.Handler()
handler.decoder.dateDecodingStrategy = .secondsSince1970
handler.decoder.keyDecodingStrategy = .useDefaultKeys

let response = try await handler(
    for: request,
    decodingTo: Response.self
)
```

### Void Requests

For requests that don't return a response body:

```swift
let request = URLRequest(url: URL(string: "https://api.example.com/logout")!)
request.httpMethod = "POST"

try await requestHandler(for: request)
```

### Error Handling

```swift
do {
    let user = try await requestHandler(
        for: request,
        decodingTo: User.self
    )
} catch RequestError.httpError(let statusCode, let message) {
    print("HTTP Error \(statusCode): \(message)")
} catch RequestError.decodingError(let context) {
    print("Decoding failed: \(context.description)")
} catch RequestError.envelopeDataMissing {
    print("Envelope response contained no data")
} catch RequestError.invalidResponse {
    print("Invalid response from server")
}
```

### Testing

In tests, the handler automatically enables debug mode:

```swift
import URLRequestHandler
import DependenciesTestSupport
import Testing

@Test
func testAPICall() async throws {
    try await withDependencies {
        $0.defaultSession = { request in
            // Mock response
            let data = """
            {"id": "123", "name": "Test User"}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    } operation: {
        @Dependency(\.defaultRequestHandler) var handler
        
        let request = URLRequest(url: URL(string: "https://api.example.com/user")!)
        let user: User = try await handler(
            for: request,
            decodingTo: User.self
        )
        
        #expect(user.id == "123")
        #expect(user.name == "Test User")
    }
}
```

### Custom URLSession

Override the default session for custom configurations:

```swift
try await withDependencies {
    $0.defaultSession = { request in
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        return try await session.data(for: request)
    }
} operation: {
    // Your code using the custom session
}
```

## API Reference

### URLRequest.Handler

The main request handler with configurable options:

```swift
public struct Handler: Sendable {
    public var debug: Bool = false
    public var decoder: JSONDecoder
    
    public init(debug: Bool = false, decoder: JSONDecoder = Self.defaultDecoder)
}
```

### RequestError

Comprehensive error types for different failure scenarios:

```swift
public enum RequestError: Error, Equatable {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(DecodingContext)
    case envelopeDataMissing
}
```

### Envelope<T>

Generic envelope type for wrapped API responses:

```swift
public struct Envelope<T> {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let timestamp: Date
}
```

## Requirements

- Swift 6.0+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## License

This package is licensed under the Apache License 2.0.