import Foundation
import os.log

enum BeaconLogger {
    static var isEnabled = false

    private static let logger = Logger(subsystem: "com.beacon.sdk", category: "Beacon")

    static func log(_ message: String) {
        guard isEnabled else { return }
        logger.info("[\u{1F4E1} Beacon] \(message)")
    }

    static func error(_ message: String) {
        guard isEnabled else { return }
        logger.error("[\u{1F4E1} Beacon] \(message)")
    }
}
