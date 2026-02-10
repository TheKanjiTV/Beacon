import Foundation

public struct BeaconConfiguration: Sendable {
    public let supabaseURL: URL
    public let supabaseKey: String
    public let flushAt: Int
    public let flushInterval: TimeInterval

    public init(
        supabaseURL: URL,
        supabaseKey: String,
        flushAt: Int = 20,
        flushInterval: TimeInterval = 30
    ) {
        self.supabaseURL = supabaseURL
        self.supabaseKey = supabaseKey
        self.flushAt = flushAt
        self.flushInterval = flushInterval
    }
}
