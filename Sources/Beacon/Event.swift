import Foundation

public struct AnyCodable: Codable, Sendable {
    public let value: any Sendable

    public init(_ value: any Sendable) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = Optional<String>.none as Any
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        default:
            try container.encodeNil()
        }
    }
}

public struct BeaconEvent: Codable, Sendable {
    public let eventName: String
    public let userId: String?
    public let sessionId: String
    public let properties: [String: AnyCodable]?
    public let deviceInfo: DeviceInfo
    public let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case userId = "user_id"
        case sessionId = "session_id"
        case properties
        case deviceInfo = "device_info"
        case timestamp
    }

    public init(
        eventName: String,
        userId: String?,
        sessionId: String,
        properties: [String: AnyCodable]?,
        deviceInfo: DeviceInfo,
        timestamp: Date = Date()
    ) {
        self.eventName = eventName
        self.userId = userId
        self.sessionId = sessionId
        self.properties = properties
        self.deviceInfo = deviceInfo
        self.timestamp = timestamp
    }
}
