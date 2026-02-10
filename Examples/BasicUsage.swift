// BasicUsage.swift
// Copy-paste example showing how to integrate Beacon into a macOS or iOS app.
// This file is not compiled as part of the package — it's a reference.

import SwiftUI
import Beacon

// MARK: - macOS App Example

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Enable debug logging (remove in production)
        Beacon.enableLogging()

        // 2. Configure with your Supabase credentials
        Beacon.configure(
            supabaseURL: "https://your-project.supabase.co",
            supabaseKey: "your-anon-key"
        )

        // 3. Track app launch
        Beacon.track("app_launched")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Flush remaining events before exit
        Beacon.shutdown()
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Beacon Example")
                .font(.title)

            Button("Track Button Tap") {
                Beacon.track("button_tapped", properties: [
                    "screen": "main",
                    "button": "example"
                ])
            }

            Button("Identify User") {
                Beacon.identify(userId: "user-123", traits: [
                    "plan": "pro",
                    "signup_source": "organic"
                ])
            }

            Button("Track Purchase") {
                Beacon.track("purchase_completed", properties: [
                    "item_id": "sku-789",
                    "price": 9.99,
                    "currency": "USD"
                ])
            }
        }
        .padding(40)
    }
}
