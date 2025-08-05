import Foundation

public struct Envelope<T> {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let timestamp: Date

    public init(success: Bool, data: T?, message: String?) {
        self.success = success
        self.data = data
        self.message = message
        self.timestamp = Date()
    }

    enum CodingKeys: String, CodingKey {
        case success, data, message, timestamp
    }
}

extension Envelope: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
}

extension Envelope: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encode(timestamp, forKey: .timestamp)
    }
}