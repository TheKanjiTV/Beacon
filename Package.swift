// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Beacon",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "Beacon", targets: ["Beacon"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Beacon",
            dependencies: [
                .product(name: "PostgREST", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "BeaconTests",
            dependencies: ["Beacon"]
        )
    ]
)
