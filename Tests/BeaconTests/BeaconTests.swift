import XCTest
@testable import Beacon

final class BeaconTests: XCTestCase {

    func testConfigurationDefaults() {
        let config = BeaconConfiguration(
            supabaseURL: URL(string: "https://example.supabase.co")!,
            supabaseKey: "test-key"
        )
        XCTAssertEqual(config.flushAt, 20)
        XCTAssertEqual(config.flushInterval, 30)
        XCTAssertEqual(config.supabaseKey, "test-key")
    }

    func testConfigurationCustomValues() {
        let config = BeaconConfiguration(
            supabaseURL: URL(string: "https://example.supabase.co")!,
            supabaseKey: "test-key",
            flushAt: 10,
            flushInterval: 60
        )
        XCTAssertEqual(config.flushAt, 10)
        XCTAssertEqual(config.flushInterval, 60)
    }

    func testEventEncodingSnakeCaseKeys() throws {
        let event = BeaconEvent(
            eventName: "button_click",
            userId: "user-123",
            sessionId: "session-456",
            properties: ["key": AnyCodable("value")],
            deviceInfo: DeviceInfo.current(),
            timestamp: Date(timeIntervalSince1970: 1700000000)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertNotNil(json["event_name"])
        XCTAssertEqual(json["event_name"] as? String, "button_click")
        XCTAssertNotNil(json["user_id"])
        XCTAssertEqual(json["user_id"] as? String, "user-123")
        XCTAssertNotNil(json["session_id"])
        XCTAssertEqual(json["session_id"] as? String, "session-456")
        XCTAssertNotNil(json["device_info"])
        XCTAssertNotNil(json["timestamp"])
        XCTAssertNotNil(json["properties"])
    }

    func testEventEncodingWithNilUserId() throws {
        let event = BeaconEvent(
            eventName: "page_view",
            userId: nil,
            sessionId: "session-789",
            properties: nil,
            deviceInfo: DeviceInfo.current()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["event_name"] as? String, "page_view")
        XCTAssertEqual(json["session_id"] as? String, "session-789")
    }

    func testDeviceInfoCurrent() {
        let info = DeviceInfo.current()
        XCTAssertFalse(info.os.isEmpty)
        XCTAssertFalse(info.osVersion.isEmpty)
        XCTAssertFalse(info.deviceModel.isEmpty)
        XCTAssertFalse(info.locale.isEmpty)
        #if os(macOS)
        XCTAssertEqual(info.os, "macOS")
        #elseif os(iOS)
        XCTAssertEqual(info.os, "iOS")
        #endif
    }

    func testDeviceInfoEncodingSnakeCaseKeys() throws {
        let info = DeviceInfo.current()
        let data = try JSONEncoder().encode(info)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertNotNil(json["os"])
        XCTAssertNotNil(json["os_version"])
        XCTAssertNotNil(json["app_name"])
        XCTAssertNotNil(json["app_version"])
        XCTAssertNotNil(json["device_model"])
        XCTAssertNotNil(json["locale"])
        // Ensure camelCase keys are NOT present
        XCTAssertNil(json["osVersion"])
        XCTAssertNil(json["appName"])
        XCTAssertNil(json["appVersion"])
        XCTAssertNil(json["deviceModel"])
    }

    func testAnyCodableEncodesString() throws {
        let codable = AnyCodable("hello")
        let data = try JSONEncoder().encode(codable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? String, "hello")
    }

    func testAnyCodableEncodesInt() throws {
        let codable = AnyCodable(42)
        let data = try JSONEncoder().encode(codable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Int, 42)
    }

    func testAnyCodableEncodesBool() throws {
        let codable = AnyCodable(true)
        let data = try JSONEncoder().encode(codable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Bool, true)
    }

    func testAnyCodableEncodesDouble() throws {
        let codable = AnyCodable(3.14)
        let data = try JSONEncoder().encode(codable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Double, 3.14)
    }
}
