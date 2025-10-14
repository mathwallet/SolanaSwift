// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolanaSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SolanaSwift",
            targets: ["SolanaSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.1"),
        .package(name: "Secp256k1Swift", url: "https://github.com/mathwallet/Secp256k1Swift.git", from: "2.0.1"),
        .package(url: "https://github.com/mathwallet/Base58Swift.git", from: "0.0.1"),
        .package(name: "TweetNacl", url: "https://github.com/lishuailibertine/tweetnacl-swiftwrap", from: "1.0.5"),
        .package(name:"BIP39swift", url: "https://github.com/mathwallet/BIP39swift", from: "2.0.1"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SolanaSwift",
            dependencies: [
                "Alamofire",
                "BIP39swift",
                .product(name: "BIP32Swift", package: "Secp256k1Swift"),
                "Base58Swift",
                "TweetNacl",
                "AnyCodable"
            ]
        ),
        .testTarget(
            name: "SolanaSwiftTests",
            dependencies: ["SolanaSwift"]),
    ]
)
