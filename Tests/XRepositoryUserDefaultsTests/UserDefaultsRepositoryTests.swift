//
//  XRepositoryUserDefaultsTests.swift
//  XRepositoryUserDefaultsTests
//
//  Created by Oleksandr Potapov on 17.12.2021.
//

import XCTest
import XRepository
@testable import XRepositoryUserDefaults

class UserDefaultsTests: XCTestCase {

  fileprivate var repository: UserDefaultsRepository<Employee>!
  
  fileprivate let testEmployees: [Employee] = [
    Employee(name: "Quirin", age: 21, data: Data()),
    Employee(name: "Stefan", age: 24, data: Data()),
    Employee(name: "Sebi", age: 22, data: Data()),
    Employee(name: "Malte" ,age: 24, data: Data()),
    Employee(name: "Joan", age: 23, data: Data()),
  ]
  
  override func setUp() {
    super.setUp()
    
    repository = UserDefaultsRepository<Employee>(suiteName: nil)
    
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
    repository.create(Employee(name: "Torsten", age: 19, data: Data()))
    repository.create(Employee(name: "Torben", age: 21, data: Data()))
    repository.create(Employee(name: "Tim", age: 87, data: Data()))
    repository.create(Employee(name: "Struppi", age: 3, data: Data()))
    
    let newEmployeeName = "Zementha"
    
    repository.create(Employee(name: newEmployeeName, age: 34, data: Data()))
    
    let filteredEmployees = repository.getElements(filteredByPredicate: \.name == newEmployeeName)
    guard let firstEmployee = filteredEmployees.first else { return }
    
    XCTAssertEqual(firstEmployee.name, newEmployeeName)
    XCTAssertEqual(filteredEmployees.count, 1)
  }
  
  func testSortingAscending() {
    let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age < $1.age })
    let filteredEmployees = repository.getElements(sortedBy: \.age)
    print(stdlibSortedEmployees, filteredEmployees)
    
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
  
  private func addRandomMockObjects(to repository: UserDefaultsRepository<Employee>) {
    let _ = repository.deleteAll()
    repository.create(testEmployees)
  }

}

class Employee: IdentifiableCodable {
  var id: String = ""
  var name: String = ""
  var age: Int = 0
  var data: Data = Data()
  
  convenience init(name: String, age: Int, data: Data) {
    self.init()
    
    self.id = name
    self.name = name
    self.age = age
    self.data = data
  }
  
  func hash(into hasher: inout Hasher) {
    return hasher.combine(id)
  }
  
  static func == (lhs: Employee, rhs: Employee) -> Bool {
    return lhs.id == rhs.id
  }
}
