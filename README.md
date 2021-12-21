<p align="center">
<br>
<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchO-333333.svg" alt="Supported Platforms: iOS, macOS, tvOS, watchOS" />
<br/>
<a><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
<a><img src="https://img.shields.io/badge/License-MIT-yellow.svg" /></a>
</p>

**XRepository** is based on [QBRepository by QuickBirds Studios](https://github.com/quickbirdstudios/QBRepository). It is lightweight implementation of Repository pattern in Swift.

## 👋🏻  Getting started
Cornerstones of this project are `protocol Repository` and `class AnyRepository` as its generic implementation. `Repository` supports basic and advanced CRUD operations. Also, you have access to out-of-the-box implementations of a few popular storages based on: `UserDefaults`, `RealmSwift`, `FileManager`, `CoreData`. But you can also create your own implementation of those ones or any other storage mechanism.
```swift
public protocol Repository {
  associatedtype Model
  ...
}

public final class AnyRepository<Model>: Repository {
  ...
}
```

## 🔧 Usage
Since `Repository` requires associated value to it, we use its generic implementation `AnyRepository`.
Usage is simple:
```swift
class ChurchesViewModel {
  ...  
  init(_ churchesRepository: AnyRepository<Church>) {
  
    let localChurch = Church(id: "hillsong-lviv", name: "Hillsong Lviv", family: "hillsong-family")
    let stateChurches = [Church(id: "hillsong-lviv", name: "Hillsong Lviv", family: "hillsong-family"), Church(id: "hillsong-odesa", name: "Hillsong Odesa", family: "hillsong-family")]
    
    // Create
    churchesRepository.create(localChurch)
    churchesRepository.create(stateChurches)
    
    // Read
    let allChurches = churchesRepository.getAll()
    let hillsongChurch = churches.getElement(withId: "hillsong")
    let hillsongFamilyChurches = churches.getElements(filterBy: \.family == "hillsong")
    
    // Update
    churchesRepository.update(Church(id: "hillsong", name: "Hillsong Kyiv", family: "hillsong-family"))
    
    // Delete
    churchesRepository.deleteAll()
    churchRepository.delete(localChurch)
    churchRepository.delete(stateChurches)
  }
  ...
}

let churchesUserDefaultsStorage = UserDefaultsRepository<Church>()
let churchesRealmStorage = RealmRepository<Church>()
let churchesCoreDataStorage = CoreDataRepository<Church>()
let churchesFileSystemStorage = FileSystemRepository<Church>()

// Any repository will fit
let churchesViewModel = ChurchesViewModel(churchesRepository: AnyRepository(churchesRealmStorage))
```

##  ⚡️ Rx
**XRepository** is a pure implementation of Repository pattern. If you want to use Rx version check my latest project: [RxXRepository](https://github.com/sashkopotapov/RxXRepository.git)

## 🍴 Instalation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/sashkopotapov/XRepository.git", .upToNextMinor(from: "1.1.0"))
]
```

## 👤 Author
This framework is created by Sashko Potapov.

## 📃 License

XCoordinator is released under an MIT license. See [License.md](https://github.com/sashkopotapov/XRepository/blob/main/LICENSE) for more information.
