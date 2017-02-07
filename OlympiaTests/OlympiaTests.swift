//
//  OlympiaTests.swift
//  OlympiaTests
//
//  Created by Jonathan Landon on 5/20/16.
//  Copyright © 2016 Oven Bits. All rights reserved.
//

import XCTest
import Olympia

struct Vehicle: Decodable {
    let make: String
    let model: String
    let year: Int?
    let prices: [Int]
    let other: [String : Int]
    let url: URL?
    let style: Style
    
    enum Style: String, Transformable {
        case coupe
        case sedan
    }
    
    init(json: JSON) throws {
        make   = try json.decode("make")
        model  = try json.decode("model")
        year   = try? json.decode("year")
        prices = json.array("prices")
        other  = json.dictionary("other")
        url    = try? json.decode("url")
        style  = try json.decode("style")
    }
}

class OlympiaTests: XCTestCase {
    
    let json: JSON = [
        "string" : "Test string",
        "date" : "2015-02-04T18:30:15.000Z",
        "color" : "#00FF00",
        "bool" : true,
        "url" : "http://ovenbits.com",
        "number": 3,
        "double" : 7.5,
        "float" : 4.75,
        "int" : -23,
        "u_int" : 25,
        "array" : [1, 2, 3, 4, 5],
        "dictionary" : [
            "string1" : "String 1",
            "string2" : "String 2",
            "string3" : "String 3"
        ]
    ]
    
    // MARK: - Data
    
    func testJSONData() {
        
        do {
            let int: Int = try json.decode("array", 5)
            print(int)
        }
        catch let error as JSON.Error {
            print("Error: \(error)")
        }
        catch {}
        
        let path = Bundle(for: OlympiaTests.self).path(forResource: "Tests", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let vehicleJSON = JSON.parse(data: data)
        
        // No data
        let emptyJSON = JSON.parse(data: nil)
        XCTAssertEqual(emptyJSON, JSON.null, "JSON is not null")
        
        // String
        XCTAssertEqual(vehicleJSON.string("make"), "BMW")
        XCTAssertEqual(vehicleJSON.string("manufacturer", "company_name"), "Bayerische Motoren Werke AG")
        XCTAssertNil(vehicleJSON.string("year"))
        
        // Number
        XCTAssertEqual(vehicleJSON.int("year"), 2015)
        XCTAssertEqual(vehicleJSON.int("purchased_trims", "sedan"), 1024)
        XCTAssertNil(vehicleJSON.int("model"))
        
        // Float
        XCTAssertEqual(vehicleJSON.float("zero_to_sixty_time"), 4.7)
        XCTAssertEqual(vehicleJSON.float("year"), 2015)
        XCTAssertNil(vehicleJSON.float("model"))
        
        // Double
        XCTAssertEqual(vehicleJSON.double("zero_to_sixty_time"), 4.7)
        XCTAssertEqual(vehicleJSON.double("year"), 2015)
        XCTAssertNil(vehicleJSON.double("model"))
        
        // Int
        XCTAssertEqual(vehicleJSON.int("year"), 2015)
        XCTAssertEqual(vehicleJSON.int("zero_to_sixty_time"), 4)
        XCTAssertNil(vehicleJSON.int("model"))
        
        // UInt
        XCTAssertEqual(vehicleJSON.uInt("year"), 2015)
        XCTAssertEqual(vehicleJSON.uInt("zero_to_sixty_time"), 4)
        XCTAssertNil(vehicleJSON.uInt("model"))
        
        // Bool
        XCTAssertEqual(vehicleJSON.bool("nav_system_standard"), true)
        XCTAssertNil(vehicleJSON.bool("model"))
        
        // URL
        XCTAssertEqual(vehicleJSON.transform("manufacturer", "website"), URL(string: "http://www.bmw.com"))
        XCTAssertNil(vehicleJSON.int("model"))
        
        // Array
        XCTAssertEqual(vehicleJSON.string("available_colors", 0), "#00304C")
        XCTAssertEqual(vehicleJSON.string("available_colors", 1), "#1C2127")
        XCTAssertEqual(vehicleJSON.string("available_colors", 2), "#D8D8D8")
        XCTAssertEqual(vehicleJSON.string("available_colors", 3), "#820F0F")
        XCTAssertEqual(vehicleJSON.array("available_colors").count, 4)
        
        // Dictionary
        XCTAssertEqual(vehicleJSON.int("purchased_trims", "sedan"), 1024)
        XCTAssertEqual(vehicleJSON.int("purchased_trims","gran_coupe"), 512)
        XCTAssertEqual(vehicleJSON.dictionary("purchased_trims").count, 2)
    }
    
    // MARK: - Create
    
    func testCreate() {
        var json = JSON()
        json["string"] = "Test String"
        json["int"] = 2
        json["uInt"] = 4
        json["float"] = 5.5
        json["bool"] = true
        json["array"] = [1, 2, 3, 4, 5]
        json["dictionary"] = ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"]
        
        XCTAssertEqual(json.string("string"), "Test String")
        XCTAssertEqual(json.int("int"), 2)
        XCTAssertEqual(json.uInt("uInt"), 4)
        XCTAssertEqual(json.float("float"), 5.5)
        XCTAssertEqual(json.bool("bool"), true)
        XCTAssertEqual(json.array("array"), [1, 2, 3, 4, 5])
        XCTAssertEqual(json.dictionary("dictionary"), ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"])
    }
    
    // MARK: - Assignment
    
    func testAssignment() {
        
        var json: JSON = [
                             "string" : "Test String",
                             "int" : 2,
                             "float" : 5.5,
                             "bool" : true,
                             "any_value" : "non-nil",
                             "array" : [1, 2, 3, 4, 5],
                             "dictionary" : [
                                                "string1" : "String 1",
                                                "string2" : "String 2",
                                                "string3" : "String 3"
            ]
        ]
        
        // Before assignment
        XCTAssertEqual(json.string("string"), "Test String")
        XCTAssertEqual(json.int("int"), 2)
        XCTAssertEqual(json.float("float"), 5.5)
        XCTAssertEqual(json.bool("bool"), true)
        XCTAssertEqual(json.string("any_value"), "non-nil")
        XCTAssertEqual(json.array("array"), [1, 2, 3, 4, 5])
        XCTAssertEqual(json.dictionary("dictionary"), ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"])
        
        // Assignment
        json["string"] = "Test String 2"
        json["int"] = 5
        json["float"] = 15.25
        json["bool"] = false
        json["any_value"] = nil
        json["array"] = [6, 7, 8, 9, 10]
        json["dictionary"] = ["string4" : "String 4", "string5" : "String 5", "string6" : "String 6"]
        
        // After assignment
        XCTAssertEqual(json.string("string"), "Test String 2")
        XCTAssertEqual(json.int("int"), 5)
        XCTAssertEqual(json.float("float"), 15.25)
        XCTAssertEqual(json.bool("bool"), false)
        XCTAssertNil(json.string("any_value"))
        XCTAssertEqual(json.array("array"), [6, 7, 8, 9, 10])
        XCTAssertEqual(json.dictionary("dictionary"), ["string4" : "String 4", "string5" : "String 5", "string6" : "String 6"])
    }
    
    // MARK: - Equatable
    
    func testEquatable() {
        var lhs: JSON = [
                            "string" : "Test String",
                            "int" : 2,
                            "float" : 5.5,
                            "bool" : true,
                            "url" : "http://ovenbits.com",
                            "array" : [1, 2, 3, 4, 5],
                            "dictionary" : [
                                               "string1" : "String 1",
                                               "string2" : "String 2",
                                               "string3" : "String 3"
            ]
        ]
        
        var rhs: JSON = [
                            "string" : "Test String",
                            "int" : 2,
                            "float" : 5.5,
                            "bool" : true,
                            "url" : "http://ovenbits.com",
                            "array" : [1, 2, 3, 4, 5],
                            "dictionary" : [
                                               "string1" : "String 1",
                                               "string2" : "String 2",
                                               "string3" : "String 3"
            ]
        ]
        
        XCTAssertTrue(lhs["string"] == rhs["string"])
        XCTAssertTrue(lhs["int"] == rhs["int"])
        XCTAssertTrue(lhs["float"] == rhs["float"])
        XCTAssertTrue(lhs["bool"] == rhs["bool"])
        XCTAssertTrue(lhs.transform("url") as URL? == rhs.transform("url") as URL?)
        XCTAssertTrue(lhs["array"] == rhs["array"])
        XCTAssertTrue(lhs["dictionary"] == rhs["dictionary"])
        XCTAssertTrue(lhs == rhs)
    }
    
    // MARK: - String
    
    func testStringLiteralConvertible() {
        let json: JSON = "abcdefg"
        
        XCTAssertEqual(json.string, "abcdefg")
    }
    
    func testString() {
        // Good value
        XCTAssertEqual(json.string("string"), "Test string")
        
        // Mistyped value
        XCTAssertNil(json.string("float"))
        XCTAssertEqual(json.string("float") ?? "", "")
        
        // Missing value
        XCTAssertNil(json.string("string2"))
        XCTAssertEqual(json.string("string2") ?? "", "")
        
        // CustomStringConvertible
        XCTAssertEqual(json["string"].description, "Test string")
        XCTAssertEqual(json["string"].debugDescription, "Test string")
    }
    
    // MARK: - NSNumber
    
    func testNumber() {
        // Good value
        XCTAssertEqual(json.int("number"), 3)
        
        // Mistyped value
        XCTAssertNil(json.int("string"))
        
        // Missing value
        XCTAssertNil(json.int("number2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["number"].description, "3")
        XCTAssertEqual(json["number"].debugDescription, "3")
    }
    
    // MARK: - Float
    
    func testFloatLiteralConvertible() {
        let json: JSON = 1.234
        
        XCTAssertEqual(json.float, 1.234)
    }
    
    func testFloat() {
        // Good value
        XCTAssertEqual(json.float("float"), 4.75)
        
        // Mistyped value
        XCTAssertNil(json.float("string"))
        
        // Missing value
        XCTAssertNil(json.float("float2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["float"].description, "4.75")
        XCTAssertEqual(json["float"].debugDescription, "4.75")
    }
    
    // MARK: - Double
    
    func testDouble() {
        // Good value
        XCTAssertEqual(json.double("double"), 7.5)
        
        // Mistyped value
        XCTAssertNil(json.double("string"))
        
        // Missing value
        XCTAssertNil(json.double("double2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["double"].description, "7.5")
        XCTAssertEqual(json["double"].debugDescription, "7.5")
    }
    
    // MARK: - Int
    
    func testIntegerLiteralConvertible() {
        let json: JSON = -2
        
        XCTAssertEqual(json.int, -2)
    }
    
    func testInt() {
        // Good value
        XCTAssertEqual(json.int("int"), -23)
        
        // Mistyped value
        XCTAssertNil(json.int("string"))
        
        // Missing value
        XCTAssertNil(json.int("int2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["int"].description, "-23")
        XCTAssertEqual(json["int"].debugDescription, "-23")
    }
    
    // MARK: - UInt
    
    func testUInt() {
        XCTAssertEqual(json.uInt("u_int"), 25)
        
        // Mistyped value
        XCTAssertNil(json.uInt("string"))
        
        // Missing value
        XCTAssertNil(json.uInt("u_int2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["u_int"].description, "25")
        XCTAssertEqual(json["u_int"].debugDescription, "25")
    }
    
    // MARK: - Bool
    
    func testBooleanLiteralConvertible() {
        let json: JSON = true
        
        XCTAssertTrue(json.bool == true)
    }
    
    func testBool() {
        // Good value
        XCTAssertTrue(json.bool("bool") == true)
        
        // Mistyped value
        XCTAssertNil(json.bool("string"))
        
        // Missing value
        XCTAssertNil(json.bool("bool2"))
        
        // CustomStringConvertible
        XCTAssertEqual(json["bool"].description, "true")
        XCTAssertEqual(json["bool"].debugDescription, "true")
    }
    
    // MARK: - URL
    
    func testURL() {
        // Good value
        XCTAssertEqual(json.transform("url"), URL(string: "http://ovenbits.com"))
        
        // Mistyped value
        XCTAssertNil(json.transform("int") as URL?)
        
        // Missing value
        XCTAssertNil(json.transform("url2") as URL?)
        
        // CustomStringConvertible
        XCTAssertEqual(json["url"].description, "http://ovenbits.com")
        XCTAssertEqual(json["url"].debugDescription, "http://ovenbits.com")
    }
    
    // MARK: - Array
    
    func testArrayLiteralConvertible() {
        let json: JSON = [1, 2, 3, 4, 5]
        
        XCTAssertEqual(json.int(0), 1)
        XCTAssertEqual(json.int(1), 2)
        XCTAssertEqual(json.int(2), 3)
        XCTAssertEqual(json.int(3), 4)
        XCTAssertEqual(json.int(4), 5)
        XCTAssertEqual(json.count, 5)
    }
    
    func testArray() {
        // Good values
        XCTAssertEqual(json.int("array", 0), 1)
        XCTAssertEqual(json.int("array", 1), 2)
        XCTAssertEqual(json.int("array", 2), 3)
        XCTAssertEqual(json.int("array", 3), 4)
        XCTAssertEqual(json.int("array", 4), 5)
        XCTAssertEqual(json.array("array").count, 5)
        
        // Mistyped values
        XCTAssertNil(json.array("string").first?.int)
        XCTAssertEqual(json.array("string").count, 0)
        
        // Missing values
        XCTAssertNil(json.array("array2").first?.int)
        XCTAssertEqual(json.array("array2").count, 0)
        
        // CollectionType
        XCTAssertEqual(json["array"].startIndex, 0)
        XCTAssertEqual(json["array"].endIndex, 5)
        XCTAssertEqual(json.int("array", 0), 1)
    }
    
    // MARK: - NSNull (from loaded data)
    
    func testNSNull() {
        let jsonPath = Bundle(for: type(of: self)).path(forResource: "Tests", ofType: "json")!
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: jsonPath))
        let json = JSON.parse(data: jsonData)
        
        XCTAssertFalse(json["driver"] != .null)
    }
    
    // MARK: - Dictionary
    
    func testDictionaryLiteralConvertible() {
        let json: JSON = [
            "string1" : "String 1",
            "string2" : "String 2",
            "string3" : "String 3"
        ]
        
        XCTAssertEqual(json.string("string1"), "String 1")
        XCTAssertEqual(json.string("string2"), "String 2")
        XCTAssertEqual(json.string("string3"), "String 3")
        XCTAssertEqual(json.dictionary.count, 3)
    }
    
    func testDictionary() {
        // Good values
        XCTAssertEqual(json.string("dictionary", "string1"), "String 1")
        XCTAssertEqual(json.string("dictionary", "string2"), "String 2")
        XCTAssertEqual(json.string("dictionary", "string3"), "String 3")
        XCTAssertEqual(json.dictionary("dictionary").count, 3)
        
        // Mistyped values
        XCTAssertEqual(json.dictionary("string").count, 0)
        
        // Missing values
        XCTAssertNil(json.string("dictionary2", "string1"))
        XCTAssertEqual(json.dictionary("dictionary2").count, 0)
        
        // Subscripts
        XCTAssertEqual(json.string("dictionary", "string1"), "String 1")
        XCTAssertEqual(json.string("dictionary", "string2"), "String 2")
        XCTAssertEqual(json.string("dictionary", "string3"), "String 3")
    }
    
    // MARK: - Raw (from loaded data)
    
    func testRaw() {
        let jsonPath = Bundle(for: type(of: self)).path(forResource: "Tests", ofType: "json")!
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: jsonPath))
        let json = JSON.parse(data: jsonData)
        
        XCTAssertFalse(json["model"].rawValue is NSNull)
        XCTAssertTrue(json["driver"].rawValue is NSNull)
        
        do {
            let data = try json.rawData()
            
            XCTAssertNotNil(data)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDict1() {
        let dict = [
            "string1" : "this is a string 1",
            "string2" : "this is a string 2",
            "string3" : "this is a string 3",
            "string4" : "this is a string 4",
            "string5" : "this is a string 5",
        ]
        measure {
            for _ in 1...100000 {
                _ = (dict as NSDictionary)["string1"]
            }
        }
    }
    
    func testDict2() {
        let dict: NSDictionary = [
            "string1" : "this is a string 1",
            "string2" : "this is a string 2",
            "string3" : "this is a string 3",
            "string4" : "this is a string 4",
            "string5" : "this is a string 5",
            ]
        measure {
            for _ in 1...100000 {
                _ = dict["string1"]
            }
        }
    }
}
