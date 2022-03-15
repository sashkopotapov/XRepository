//
//  File.swift
//  
//
//  Created by Oleksandr Potapov on 12.03.2022.
//

import Foundation
import XRepository
import RxSwift
import RxRelay

public protocol Identifiable: Hashable {
  associatedtype Identifier: Hashable
  var id: Identifier { get }
}

public final class BufferRepository<Model: Identifiable>: Repository {
  public typealias Model = Model
  
  let scheduler: ConcurrentDispatchQueueScheduler
  private let queue: DispatchQueue
  private let semaphore: DispatchSemaphore
  private let storage: BehaviorRelay<Set<Model>>
  
  public init() {
    self.queue = DispatchQueue(label: "io.queue.persistence", attributes: .concurrent)
    self.scheduler = ConcurrentDispatchQueueScheduler(queue: queue)
    self.semaphore = DispatchSemaphore(value: 1)
    self.storage = BehaviorRelay(value: Set())
  }
  
  public func getAll() -> AnyRandomAccessCollection<Model> {
    var result: Set<Model>?
    queue.sync(execute: { result = storage.value })
    return AnyRandomAccessCollection(Array(result ?? Set()))
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
    
    return objects
  }
  
  @discardableResult public func create(_ model: Model) -> RepositoryEditResult<Model> {
    semaphore.wait()
    queue.sync(execute: {
      var objects = storage.value
      guard !objects.contains(model) else { return }
      objects.insert(model)
      self.replaceExistingValue(with: objects)
      self.semaphore.signal()
    })
    return .success(model)
  }
  
  @discardableResult public func create(_ models: [Model]) -> RepositoryEditResult<[Model]> {
    semaphore.wait()
    queue.sync(execute: {
      var objects = storage.value
      guard Set(models).intersection(objects).isEmpty else { return }
      objects.formUnion(models)
      self.replaceExistingValue(with: objects)
      self.semaphore.signal()
    })
    return .success(models)
  }
  
  @discardableResult public func update(_ model: Model) -> RepositoryEditResult<Model> {
    semaphore.wait()
    queue.sync(execute: {
      var objects = storage.value
      guard objects.contains(model) else { return }
      objects.update(with: model)
      self.replaceExistingValue(with: objects)
      self.semaphore.signal()
    })
    return .success(model)
  }
  
  @discardableResult public func delete(_ model: Model) -> Error? {
    semaphore.wait()
    queue.sync(execute: {
      var objects = storage.value
      guard objects.contains(model) else { return }
      objects.remove(model)
      self.replaceExistingValue(with: objects)
      self.semaphore.signal()
    })
    return nil
  }
  
  @discardableResult public func delete(_ models: [Model]) -> Error? {
    semaphore.wait()
    queue.sync(execute: {
      var objects = storage.value
      guard Set(models).isSubset(of: objects) else { return }
      objects.subtract(models)
      self.replaceExistingValue(with: objects)
      self.semaphore.signal()
    })
    return nil
  }
  
  @discardableResult public func deleteAll() -> Error? {
    semaphore.wait()
    queue.sync(execute: {
      self.replaceExistingValue(with: Set())
      self.semaphore.signal()
    })
    return nil
  }
  
  @discardableResult public func performTranscation(_ transaction: () -> Void) -> Error? {
    transaction()
    return nil
  }
  
  @discardableResult private func replaceExistingValue(with objects: Set<Model>) -> Error? {
    queue.async(flags: .barrier, execute: { self.storage.accept(objects) })
    return nil
  }
}
