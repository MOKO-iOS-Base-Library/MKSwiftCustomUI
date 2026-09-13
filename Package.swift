// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MKSwiftCustomUI",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "MKSwiftCustomUI",
            targets: ["MKSwiftCustomUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", .upToNextMajor(from: "2.8.4")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", .upToNextMajor(from: "3.7.6")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/raulriera/TextFieldEffects.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.16"),
        .package(url: "https://github.com/jmcnamara/libxlsxwriter", from: "1.2.3"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseSwiftModule.git", from: "1.0.15"),
    ],
    targets: [
        .target(
            name: "MKSwiftCustomUI",
            dependencies: [
                .product(name: "DeviceKit", package: "DeviceKit"),
                .product(name: "FSCalendar", package: "FSCalendar"),
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "MJRefresh", package: "MJRefresh"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "TextFieldEffects", package: "TextFieldEffects"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "libxlsxwriter", package: "libxlsxwriter"),
                .product(name: "MKBaseSwiftModule", package: "MKBaseSwiftModule"),
            ],
            path: "Sources",
            resources: [
                .process("Assets")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("IOS18_OR_LATER")
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("iconv")
            ]
        ),
        .testTarget(
            name: "MKSwiftCustomUITests",
            dependencies: ["MKSwiftCustomUI"])
    ]
)
