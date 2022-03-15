// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "XRepository",
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "XRepository",
      targets: ["XRepository"]),
  
    .library(
      name: "XRepositoryFileSystem",
      targets: ["XRepositoryFileSystem"]),
    
    .library(
      name: "XRepositoryRealm",
      targets: ["XRepositoryRealm"]),
    
    .library(
      name: "XRepositoryBuffer",
      targets: ["XRepositoryBuffer"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/realm/realm-cocoa.git", from: "10.24.1"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "XRepository",
      dependencies: []),
    
    .target(
      name: "XRepositoryFileSystem",
      dependencies: ["XRepository"]),
    
    .target(
      name: "XRepositoryRealm",
      dependencies: [
        "XRepository",
        .product(name: "RealmSwift", package: "realm-cocoa"),
        .product(name: "Realm", package: "realm-cocoa")
      ]),
    
    .target(
      name: "XRepositoryBuffer",
      dependencies: [
        "XRepository",
        .product(name: "RxRelay", package: "RxSwift")
      ]),
    
    // Test Targets
    .testTarget(
      name: "XRepositoryTests",
      dependencies: ["XRepository"]),
    
    .testTarget(
      name: "XRepositoryFileSystemTests",
      dependencies: ["XRepository", "XRepositoryFileSystem"]),
    
    .testTarget(
      name: "XRepositoryRealmTests",
      dependencies: [
        "XRepository",
        "XRepositoryRealm",
        .product(name: "RealmSwift", package: "realm-cocoa"),
        .product(name: "Realm", package: "realm-cocoa")
      ]),
    
    .testTarget(
      name: "XRepositoryBufferTests",
      dependencies: ["XRepository", "XRepositoryBuffer"])
  ]
)
