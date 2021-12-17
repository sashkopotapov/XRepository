<p align="center">
<br>
<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchO-333333.svg" alt="Supported Platforms: iOS, macOS, tvOS, watchOS" />
<br/>
<a><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
<a><img src="https://img.shields.io/badge/License-MIT-yellow.svg" /></a>
</p>

**XRepository** is based on [QBRepository by QuickBirds Studios](https://github.com/quickbirdstudios/QBRepository). It is lightweight implementation of Repository pattern in Swift.

## 👋🏻  Getting started
Cornerstone of this project is `Repository`  protocol.
```swift
protocol  Repository {
  associatedtype  Model

  func getAll() -> AnyRandomAccessCollection<Model>
  func getElement<Id>(withId id: Id) -> Model?
  func getElements(filteredBy filter: Query<Model>?, sortedBy sortKeyPath: ComparableKeyPath<Model>?, distinctUsing distinctMode: HashableKeyPath<Model>?) -> AnyRandomAccessCollection<Model>
  func  create(_ model: Model) -> RepositoryEditResult<Model>
  func  create(_ models: [Model]) -> RepositoryEditResult<[Model]>
  func  update(_ model: Model) -> RepositoryEditResult<Model>
  func  delete(_ model: Model) -> Error?
  func delete(_ models: [Model]) -> Error?
  func  deleteAll() -> Error?
  func performTranscation(_ transaction: () -> Void) -> Error?
}
```

Than you have `AnyRepository` class to abstragate implementation of `Repository` from its consumers. `AnyRepository` has the same semantic as its interface.

```swift
final class AnyRepository<Model>: Repository {
  ...
  init <A: Repository>(_ repository: A) where A.Model == Model { ... }
  ...
}
```
## 🔧 Usage
**XRepository** provides implementations for popular storages from-the-box:
`UserDefaultRepository`, ` RealmRepository`, `FileSystemRepository`, but you can create your own implementation.
Usage is simple:
```swift
class ChurchesViewModel {
  ...
  let churchesRepository: AnyRepository<Church>
  ...
}

let churchesStorage = AnyRepository(UserDefaultsRepository<Church>())
let churchesViewModel = ChurchesViewModel(churchesRepository: churchesStorage)
```

##  ⚡️ Rx
**XRepository** supports reactive wrapper over `AnyRepository`
```swift
extension  AnyRepository {
  var rx: RxRepository<Model> {
    return RxRepository(self)
  }
}

class  RxRepository<Model> {

  let  base: AnyRepository<Model>
  
  init(_ base: AnyRepository<Model>) {
    self.base = base
  }
  
  func getAll() -> Single<AnyRandomAccessCollection<Model>> {
    return Single.create(subscribe: { single -> Disposable in
      let models = self.base.getAll() 
      single(.success(models))
      return Disposables.create()
     })
  }
  ....
  
 }
```
If you want  a pure reactive repository implementations for popular storages, check my latest project: [ReactiveXRepository](https://github.com/sashkopotapov/ReactiveXRepository.git)

## 👤 Author
This framework is created by Sashko Potapov.

## 📃 License

XCoordinator is released under an MIT license. See [License.md](https://github.com/sashkopotapov/XRepository/blob/main/LICENSE) for more information.
