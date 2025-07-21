// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimeCapsuleCamera",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TimeCapsuleCamera",
            targets: ["TimeCapsuleCamera"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "TimeCapsuleCamera",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            ],
            path: ".",
            sources: [
                "TimeCapsuleCameraApp.swift",
                "Models/",
                "Views/",
                "ViewModels/",
                "Services/"
            ]
        ),
    ]
)