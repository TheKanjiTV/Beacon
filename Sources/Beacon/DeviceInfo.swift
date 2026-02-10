import Foundation

public struct DeviceInfo: Codable, Sendable {
    public let os: String
    public let osVersion: String
    public let appName: String
    public let appVersion: String
    public let deviceModel: String
    public let locale: String

    enum CodingKeys: String, CodingKey {
        case os
        case osVersion = "os_version"
        case appName = "app_name"
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case locale
    }

    public static func current() -> DeviceInfo {
        let version = ProcessInfo.processInfo.operatingSystemVersion

        #if os(macOS)
        let osName = "macOS"
        #elseif os(iOS)
        let osName = "iOS"
        #else
        let osName = "unknown"
        #endif

        let osVersionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        let model = DeviceInfo.hardwareModel()

        return DeviceInfo(
            os: osName,
            osVersion: osVersionString,
            appName: appName,
            appVersion: appVersion,
            deviceModel: model,
            locale: Locale.current.identifier
        )
    }

    private static func hardwareModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        guard size > 0 else { return "Unknown" }
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
}
