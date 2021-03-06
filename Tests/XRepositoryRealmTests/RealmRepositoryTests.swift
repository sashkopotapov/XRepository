//
//  XRepositoryRealmTests.swift
//  XRepositoryRealmTests
//
//  Created by Oleksandr Potapov on 17.12.2021.
//

import XCTest
import XRepository
import RealmSwift
@testable import XRepositoryRealm

class RealmRepositoryTests: XCTestCase {
  
  fileprivate var repository: RealmRepository<QuickEmployee>!
  
  fileprivate let testEmployees: [QuickEmployee] = [
    QuickEmployee(name: "Quirin", age: 21, data: Data()),
    QuickEmployee(name: "Stefan", age: 24, data: Data()),
    QuickEmployee(name: "Sebi", age: 22, data: Data()),
    QuickEmployee(name: "Malte" ,age: 24, data: Data()),
    QuickEmployee(name: "Joan", age: 23, data: Data()),
  ]
  
  override func setUp() {
    super.setUp()
    
    let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TestRealm"))
    repository = RealmRepository<QuickEmployee>(realm: testRealm)
    
    addRandomMockObjects(to: repository)
  }
  
  func testGetAll() {
    let allObjects = repository.getAll()
    XCTAssertEqual(allObjects.underestimatedCount, testEmployees.count)
  }
  
  
  func testDeleteAll() {
    let deletionError = repository.deleteAll()
    let allObjects = repository.getAll()
    
    XCTAssert(allObjects.isEmpty && deletionError == nil)
  }
  
  func testFilter() {
    repository.create(QuickEmployee(name: "Torsten", age: 19, data: Data()))
    repository.create(QuickEmployee(name: "Torben", age: 21, data: Data()))
    repository.create(QuickEmployee(name: "Tim", age: 87, data: Data()))
    repository.create(QuickEmployee(name: "Struppi", age: 3, data: Data()))
    
    let newEmployeeName = "Zementha"
    repository.create(QuickEmployee(name: newEmployeeName, age: 34, data: Data()))
    
    let filteredEmployees = repository.getElements(filteredByPredicate: \.name == newEmployeeName)
    guard let firstEmployee = filteredEmployees.first else { return }
    
    XCTAssertEqual(firstEmployee.name, newEmployeeName)
    XCTAssertEqual(filteredEmployees.count, 1)
  }
  
  func testSortingAscending() {
    let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age < $1.age })
    let filteredEmployees = repository.getElements(sortedBy: \.age)
    
    XCTAssert(filteredEmployees.first?.age == stdlibSortedEmployees.first?.age)
    XCTAssert(filteredEmployees.last?.age == stdlibSortedEmployees.last?.age)
  }
  
  func testSortingDescending() {
    let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age > $1.age })
    let filteredEmployees = repository.getElements(sortedBy: \.age).reversed()
    
    XCTAssert(filteredEmployees.first?.age == stdlibSortedEmployees.first?.age)
    XCTAssert(filteredEmployees.last?.age == stdlibSortedEmployees.last?.age)
  }
  
  func testDistinct() {
    let stdlibFilteredAges = Set(testEmployees.map { $0.age })
    let distinctAgeEmployees = repository.getElements(distinctUsing: \.age)
    let ages = distinctAgeEmployees.map { $0.age }
    
    XCTAssert(stdlibFilteredAges.count == ages.count)
  }
  
  // MARK: Helper Methods
  
  private func addRandomMockObjects(to repository: RealmRepository<QuickEmployee>) {
    repository.deleteAll()
    repository.create(testEmployees)
  }
}

class QuickEmployee: Object {
  @objc dynamic var name: String = ""
  @objc dynamic var age: Int = 0
  @objc dynamic var data: Data = Data()
  
  convenience init(name: String, age: Int, data: Data) {
    self.init()
    
    self.name = name
    self.age = age
    self.data = data
  }
  
  override static func primaryKey() -> String? {
    return "name"
  }
}
