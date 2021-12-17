//
//  UserDefaultsRepository.swift
//  XRepositoryUserDefaults
//
//  Created by Oleksandr Potapov on 17.12.2021.
//

import Foundation
import XRepository

public protocol IdentifiableCodable: Codable, Hashable {
  associatedtype Identifier: Hashable
  var id: Identifier { get }
}

public final class UserDefaultsRepository<Object: IdentifiableCodable>: Repository {
  public typealias Model = Object
  
  private let key = "\(Object.self)"
  private let userDefault: UserDefaults
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  
  public init(suiteName: String? = nil, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
    self.encoder = encoder
    self.decoder = decoder
    
    if let suiteName = suiteName {
      self.userDefault = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    } else {
      self.userDefault = UserDefaults.standard
    }
  }
  
  public func getAll() -> AnyRandomAccessCollection<Model> {
    guard let data = userDefault.value(forKey: key) as? Data else { return AnyRandomAccessCollection([]) }
    
    do {
      return AnyRandomAccessCollection(Array(try decoder.decode(Set<Model>.self, from: data)))
    } catch {
      return AnyRandomAccessCollection([])
    }
  }
  
  public func getElement<Identifier>(withId id: Identifier) -> Model? {
    guard let correctId = id as? Model.Identifier else { return nil }
    let allData = self.getAll()
    return allData.filter({ $0.id == correctId }).first ?? nil
  }
  
  public func getElements(filteredBy filter: Query<Model>?, sortedBy sortKeyPath: ComparableKeyPath<Model>?, distinctUsing distinctMode: HashableKeyPath<Model>?) -> AnyRandomAccessCollection<Model> {
    var objects = self.getAll()
    
    if let query = filter {
      let result = objects.filter({ query.evaluate($0) })
      objects = AnyRandomAccessCollection(result)
    }
    
    if let sortKeyPath = sortKeyPath {
      let result = objects.sorted(by: sortKeyPath.isSmaller)
      objects = AnyRandomAccessCollection(result)
    }
    
    if let distinctKeyPath = distinctMode {
      let grouped = Dictionary(grouping: objects, by: distinctKeyPath.hashValue)
      let result = grouped.values.compactMap(\.first)
      objects = AnyRandomAccessCollection(result)
    }
    
    return AnyRandomAccessCollection(objects)
  }
  
  public func create(_ model: Model) -> RepositoryEditResult<Object> {
    var objects = Set(self.getAll())
    guard !objects.contains(model) else { return .error(UserDefaultsRepositoryError.valueAlreadyExists(model)) }
    
    objects.insert(model)
    
    if let error = self.replaceExistingValue(with: objects) { return .error(error) }
    return .success(model)
  }
  
  public func create(_ models: [Model]) -> RepositoryEditResult<[Object]> {
    var objects = Set(self.getAll())
    guard Set(models).intersection(objects).isEmpty else { return .error(UserDefaultsRepositoryError.valuesAlreadyExist(models)) }
    
    objects.formUnion(models)
    
    if let error = self.replaceExistingValue(with: objects) { return .error(error) }
    return .success(models)
  }
  
  public func update(_ model: Model) -> RepositoryEditResult<Object> {
    var objects = Set(getAll())
    guard objects.contains(model) else { return .error(UserDefaultsRepositoryError.noSuchModelInDatabase(model)) }
    
    objects.update(with: model)
    
    if let error = self.replaceExistingValue(with: objects) { return .error(error) }
    return .success(model)
  }
  
  public func delete(_ model: Object) -> Error? {
    var objects = Set(self.getAll())
    guard objects.contains(model) else { return UserDefaultsRepositoryError.noSuchModelInDatabase(model) }
    
    objects.remove(model)
    
    if let error = self.replaceExistingValue(with: objects) { return error }
    return nil
  }
  
  public func delete(_ models: [Model]) -> Error? {
    var objects = Set(self.getAll())
    guard Set(models).isSubset(of: objects) else { return UserDefaultsRepositoryError.noSuchModelsInDatabase(models) }
    
    objects.subtract(models)
    
    if let error = self.replaceExistingValue(with: objects) { return error }
    return nil
  }
  
  public func deleteAll() -> Error? {
    userDefault.removeObject(forKey: key)
    return nil
  }
  
  public func performTranscation(_ transaction: () -> Void) -> Error? {
    transaction()
    return nil
  }
  
  private func replaceExistingValue(with objects: Set<Model>) -> Error? {
    do {
      userDefault.set(try encoder.encode(objects), forKey: key)
      return nil
    } catch {
      return error
    }
  }
  
}

extension UserDefaultsRepository {
  enum UserDefaultsRepositoryError: Error {
    case valueAlreadyExists(Model)
    case valuesAlreadyExist([Model])
    case noSuchModelInDatabase(Model)
    case noSuchModelsInDatabase([Model])
  }
}

