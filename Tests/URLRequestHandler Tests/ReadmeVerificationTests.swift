import DependenciesTestSupport
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import Testing

@testable import URLRequestHandler

@Suite("README Verification Tests")
struct ReadmeVerificationTests {

  // MARK: - Basic Request Handling (Lines 49-71)

  @Test("README Line 49-71: Basic Request Handling")
  func testBasicRequestHandling() async throws {
    struct User: Decodable {
      let id: String
      let name: String
      let email: String
    }

    try await withDependencies {
      $0.defaultSession = { request in
        let data = """
          {"id": "123", "name": "John Doe", "email": "john@example.com"}
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
      @Dependency(\.defaultRequestHandler) var requestHandler

      let request = URLRequest(url: URL(string: "https://api.example.com/users/123")!)

      let user: User = try await requestHandler(
        for: request,
        decodingTo: User.self
      )

      #expect(user.id == "123")
      #expect(user.name == "John Doe")
      #expect(user.email == "john@example.com")
    }
  }

  // MARK: - Envelope Response Pattern (Lines 73-93)

  @Test("README Line 73-93: Envelope Response Pattern")
  func testEnvelopeResponsePattern() async throws {
    struct User: Decodable {
      let id: String
      let name: String
    }

    try await withDependencies {
      $0.defaultSession = { request in
        let data = """
          {
            "success": true,
            "data": { "id": "123", "name": "John" },
            "message": "User fetched successfully",
            "timestamp": "2024-01-01T00:00:00Z"
          }
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
      @Dependency(\.defaultRequestHandler) var requestHandler

      let request = URLRequest(url: URL(string: "https://api.example.com/user")!)

      let user: User = try await requestHandler(
        for: request,
        decodingTo: User.self
      )

      #expect(user.id == "123")
      #expect(user.name == "John")
    }
  }

  // MARK: - Custom JSON Decoder (Lines 95-106)

  @Test("README Line 95-106: Custom JSON Decoder")
  func testCustomJSONDecoder() async throws {
    struct Response: Decodable {
      let id: String
    }

    try await withDependencies {
      $0.defaultSession = { request in
        let data = """
          {"id": "123"}
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
      let handler = URLRequest.Handler()
      handler.decoder.dateDecodingStrategy = .secondsSince1970
      handler.decoder.keyDecodingStrategy = .useDefaultKeys

      let request = URLRequest(url: URL(string: "https://api.example.com/test")!)

      let response: Response = try await handler(
        for: request,
        decodingTo: Response.self
      )

      #expect(response.id == "123")
    }
  }

  // MARK: - Void Requests (Lines 108-117)

  @Test("README Line 108-117: Void Requests")
  func testVoidRequests() async throws {
    try await withDependencies {
      $0.defaultSession = { request in
        let response = HTTPURLResponse(
          url: request.url!,
          statusCode: 204,
          httpVersion: nil,
          headerFields: nil
        )!
        return (Data(), response)
      }
    } operation: {
      @Dependency(\.defaultRequestHandler) var requestHandler

      var request = URLRequest(url: URL(string: "https://api.example.com/logout")!)
      request.httpMethod = "POST"

      // Should not throw
      try await requestHandler(for: request)
    }
  }

  // MARK: - Error Handling (Lines 119-136)

  @Test("README Line 119-136: Error Handling")
  func testErrorHandling() async throws {
    struct User: Decodable {
      let id: String
    }

    // Test HTTP Error
    try await withDependencies {
      $0.defaultSession = { request in
        let data = """
          {"message": "Not found"}
          """.data(using: .utf8)!
        let response = HTTPURLResponse(
          url: request.url!,
          statusCode: 404,
          httpVersion: nil,
          headerFields: nil
        )!
        return (data, response)
      }
    } operation: {
      @Dependency(\.defaultRequestHandler) var requestHandler

      let request = URLRequest(url: URL(string: "https://api.example.com/user")!)

      do {
        let _ = try await requestHandler(
          for: request,
          decodingTo: User.self
        )
        Issue.record("Expected HTTP error")
      } catch RequestError.httpError(let statusCode, let message) {
        #expect(statusCode == 404)
        #expect(message.contains("Not found"))
      }
    }
  }

  // MARK: - Testing with Mocks (Lines 140-176)

  @Test("README Line 140-176: Testing with Mocks")
  func testTestingWithMocks() async throws {
    struct User: Decodable {
      let id: String
      let name: String
    }

    try await withDependencies {
      $0.defaultSession = { request in
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

  // MARK: - Custom URLSession (Lines 178-193)

  @Test("README Line 178-193: Custom URLSession")
  func testCustomURLSession() async throws {
    struct Response: Decodable {
      let id: String
    }

    try await withDependencies {
      $0.defaultSession = { request in
        // Custom session configuration would be applied here
        let data = """
          {"id": "123"}
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

      let request = URLRequest(url: URL(string: "https://api.example.com/test")!)
      let response: Response = try await handler(
        for: request,
        decodingTo: Response.self
      )

      #expect(response.id == "123")
    }
  }

  // MARK: - URLRequest.Handler API (Lines 198-208)

  @Test("README Line 198-208: URLRequest.Handler API")
  func testHandlerAPI() {
    let handler = URLRequest.Handler(debug: false, decoder: JSONDecoder())

    #expect(handler.debug == false)

    let customDecoder = JSONDecoder()
    customDecoder.dateDecodingStrategy = .iso8601
    let handlerWithCustomDecoder = URLRequest.Handler(debug: true, decoder: customDecoder)

    #expect(handlerWithCustomDecoder.debug == true)
  }

  // MARK: - RequestError Types (Lines 210-222)

  @Test("README Line 210-222: RequestError Types")
  func testRequestErrorTypes() {
    let invalidResponseError = RequestError.invalidResponse
    let httpError = RequestError.httpError(statusCode: 404, message: "Not found")
    let envelopeDataMissingError = RequestError.envelopeDataMissing

    #expect(invalidResponseError == .invalidResponse)

    if case .httpError(let code, let msg) = httpError {
      #expect(code == 404)
      #expect(msg == "Not found")
    }

    #expect(envelopeDataMissingError == .envelopeDataMissing)
  }

  // MARK: - Envelope Structure (Lines 224-239)

  @Test("README Line 224-239: Envelope Structure")
  func testEnvelopeStructure() throws {
    struct TestData: Codable, Equatable {
      let value: String
    }

    let envelope = Envelope<TestData>(
      success: true,
      data: TestData(value: "test"),
      message: "Success"
    )

    #expect(envelope.success == true)
    #expect(envelope.data == TestData(value: "test"))
    #expect(envelope.message == "Success")
    #expect(envelope.timestamp <= Date())

    // Test encoding/decoding
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(envelope)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(Envelope<TestData>.self, from: data)

    #expect(decoded.success == envelope.success)
    #expect(decoded.data == envelope.data)
    #expect(decoded.message == envelope.message)
  }
}
