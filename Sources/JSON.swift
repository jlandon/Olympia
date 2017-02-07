//
//  JSON.swift
//  Olympia
//
//  Created by Jonathan Landon on 2/29/16.
//

import Foundation

public enum JSON {
    case arr([JSON])
    case dict([String : JSON])
    case str(String)
    case i(Int)
    case d(Double)
    case b(Bool)
    case null
}

// MARK: - Initializers

extension JSON {

    public init?(data: Data?, options: JSONSerialization.ReadingOptions = [.allowFragments]) {
        guard
            let data = data,
            let object = try? JSONSerialization.jsonObject(with: data, options: options) as AnyObject,
            let json = JSON(object: object)
        else { return nil }
        
        self = json
    }
    
    public init?(object: Any?) {
        func parse(number: NSNumber) -> JSON {
            switch number {
            case _ where CFNumberGetType(number) == .charType:
                return .b(number.boolValue)
            case _ where !CFNumberIsFloatType(number):
                return .i(number.intValue)
            default:
                return .d(number.doubleValue)
            }
        }
        
        switch object {
        case let array as [AnyObject]:               self = .arr(array.map(JSON.parse))
        case let dictionary as [String : AnyObject]: self = .dict(dictionary.map(JSON.parse))
        case let string as String:                   self = .str(string)
        case let number as NSNumber:                 self = parse(number: number)
        default:                                     return nil
        }
    }
    
    public init() {
        self = .null
    }
    
    public static func parse(data: Data?, options: JSONSerialization.ReadingOptions = [.allowFragments]) -> JSON {
        return data.flatMap { JSON(data: $0, options: options) } ?? .null
    }
    
    public static func parse(object: Any?) -> JSON {
        return JSON(object: object) ?? .null
    }
    
    public static func parse(stringObject: String?) -> JSON {
        let data = stringObject?.data(using: .utf8)
        return JSON(data: data) ?? .null
    }
}

// MARK: - Serialize

extension JSON {

    public func unparse(_ previous: AnyObject? = nil) -> AnyObject {
        switch self {
        case .arr(let arr):    return NSArray(array: arr.map { $0.unparse(previous) })
        case .dict(let dict):  return NSDictionary(dictionary: Dictionary(pairs: dict.map { ($0, $1.unparse(previous)) }))
        case .str(let string): return NSString(string: string)
        case .d(let double):   return NSNumber(value: double)
        case .i(let int):      return NSNumber(value: int)
        case .b(let bool):     return NSNumber(value: bool)
        case .null:            return NSNull()
        }
    }
    
    public func stringify(prettyPrint: Bool = true) -> String {
        switch self {
        case .arr, .dict:
            let data = try? rawData(prettyPrint ? [.prettyPrinted] : [])
            return data.flatMap { String(data: $0, encoding: .utf8) } ?? "null"
        case .str(let string): return string
        case .i(let int):      return "\(int)"
        case .d(let double):   return "\(double)"
        case .b(let bool):     return "\(bool)"
        case .null:            return "null"
        }
    }
    
}

// MARK: - Value and subscript

extension JSON {
    
    public subscript(key: Path) -> JSON {
        set {
            switch self {
            case .dict(var dictionary):
                if let key = key as? String {
                    dictionary[key] = newValue
                    self = .dict(dictionary)
                }
            default:
                if let key = key as? String {
                    self = .dict([key : newValue])
                }
            }
        }
        get {
            return value(for: [key])
        }
    }
    
    // Get non-throwing JSON value at key path
    fileprivate func value(for keys: [Path]) -> JSON {
        return (try? throwingValue(for: keys)) ?? .null
    }
    
    // Get throwing JSON value at key path
    fileprivate func throwingValue(for keys: [Path]) throws -> JSON {
        var json = self
        
        for key in keys {
            json = try json.value(at: key)
        }
        
        return json
    }
    
    // Get JSON value at key
    fileprivate func value(at key: Path) throws -> JSON {
        switch self {
        case .dict(let dictionary):
            return try key.value(in: dictionary)
        case .arr(let array):
            return try key.value(in: array)
        default:
            return .null
        }
    }
    
}

// MARK: - RawRepresentable

extension JSON: RawRepresentable {
    
    public enum DataError: Swift.Error {
        case missing
        case invalid(object: AnyObject)
    }
    
    public init?(rawValue: AnyObject) {
        guard JSONSerialization.isValidJSONObject(rawValue) else { return nil }
        self = JSON.parse(object: rawValue)
    }
    
    public var rawValue: AnyObject {
        return unparse()
    }
    
    public func rawData(_ options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard !(rawValue is NSNull) else { throw DataError.missing }
        guard JSONSerialization.isValidJSONObject(rawValue) else { throw DataError.invalid(object: rawValue) }
        
        return try JSONSerialization.data(withJSONObject: rawValue, options: options)
    }
    
}

// MARK: - Error

extension JSON {
    
    public enum Error: Swift.Error, CustomStringConvertible {
        case inconvertible(value: JSON, to: Any.Type)
        case missing(key: String)
        case outOfBounds(index: Int)
        case invalidSubscript(type: Path.Type, value: Any)
        
        public var description: String {
            switch self {
            case .inconvertible(value: let json, to: let type):
                return "\(json) inconvertible to type: \(type)"
            case .missing(key: let key):
                return "Missing key: \(key)"
            case .outOfBounds(index: let index):
                return "Index out of bounds: \(index)"
            case .invalidSubscript(type: let type, value: let value):
                return "Invalid subscript type: \(type) (\(value))"
            }
        }
    }
    
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    
    public var description: String {
        return stringify()
    }
    
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return description
    }
    
}

// MARK: - Default value

extension JSON {
    
    public func value<T: Transformable>(_ key: Path, default: T) -> T {
        return self.transform(key) ?? `default`
    }
    
    public func value<T: Decodable>(_ key: Path, default: T) -> T {
        return self.transform(key) ?? `default`
    }
    
}

// MARK: - Transform

extension JSON {
    
    public func transform<T: Transformable>(_ keys: Path...) -> T? {
        return try? T.deserialize(json: value(for: keys))
    }
    
    public func transform<T: Decodable>(_ keys: Path...) -> T? {
        return try? T(json: value(for: keys))
    }
    
}

// MARK: - Decode

extension JSON {
    
    public func decode<T: Transformable>(_ keys: Path...) throws -> T {
        return try T.deserialize(json: throwingValue(for: keys))
    }
    
    public func decode<T: Decodable>(_ keys: Path...) throws -> T {
        return try T(json: throwingValue(for: keys))
    }
    
    public func decode<T: Transformable>(_ keys: Path...) throws -> [T] {
        return try throwingValue(for: keys).flatMap { try T.deserialize(json: $0) }
    }
    
    public func decode<T: Decodable>(_ keys: Path...) throws -> [T] {
        return try throwingValue(for: keys).flatMap { try T(json: $0) }
    }
    
    public func decode<T: Decodable>(_ keys: Path...) throws -> [String : T] {
        return try Dictionary(pairs: throwingValue(for: keys).dictionary.map { ($0, try T(json: $1)) })
    }
    
    public func decode(_ keys: Path...) throws -> String {
        return try String(json: throwingValue(for: keys))
    }

    public func decode(_ keys: Path...) throws -> Int {
        return try Int(json: throwingValue(for: keys))
    }
    
    public func decode(_ keys: Path...) throws -> Double {
        return try Double(json: throwingValue(for: keys))
    }
    
    public func decode(_ keys: Path...) throws -> Bool {
        return try Bool(json: throwingValue(for: keys))
    }
    
    public func decode(_ keys: Path...) throws -> Float {
        return try Float(json: throwingValue(for: keys))
    }
    
    public func decode(_ keys: Path...) throws -> UInt {
        return try UInt(json: throwingValue(for: keys))
    }
    
}

// MARK: - Collection

extension JSON: Collection {
    
    public var startIndex: Int {
        return array.startIndex
    }
    
    public var endIndex: Int {
        return array.endIndex
    }
    
    public subscript(position: Int) -> JSON {
        return array[position]
    }
    
    public func index(after i: Int) -> Int {
        return array.index(after: i)
    }
    
}

// MARK: - String

extension JSON {
    public var string: String? {
        return try? String(json: self)
    }
    
    public func string(_ keys: Path...) -> String? {
        return value(for: keys).string
    }
}

// MARK: - Int

extension JSON {
    
    public var int: Int? {
        return try? Int(json: self)
    }
    
    public func int(_ keys: Path...) -> Int? {
        return value(for: keys).int
    }
    
}

// MARK: - Double

extension JSON {
    
    public var double: Double? {
        return try? Double(json: self)
    }
    
    public func double(_ keys: Path...) -> Double? {
        return value(for: keys).double
    }
    
}

// MARK: - Bool

extension JSON {
    
    public var bool: Bool? {
        return try? Bool(json: self)
    }
    
    public func bool(_ keys: Path...) -> Bool? {
        return value(for: keys).bool
    }
    
}

// MARK: - Float

extension JSON {
    
    public var float: Float? {
        return try? Float(json: self)
    }
    
    public func float(_ keys: Path...) -> Float? {
        return value(for: keys).float
    }
    
}

// MARK: - UInt

extension JSON {
    
    public var uInt: UInt? {
        return try? UInt(json: self)
    }
    
    public func uInt(_ keys: Path...) -> UInt? {
        return value(for: keys).uInt
    }
    
}

// MARK: - Array

extension JSON {
    
    public var array: [JSON] {
        guard case .arr(let array) = self else { return [] }
        return array
    }
    
    public func array(_ keys: Path...) -> [JSON] {
        return value(for: keys).array
    }
    
    public func array<T: Decodable>(_ keys: Path...) -> [T] {
        return value(for: keys).flatMap(T.decode)
    }
    
    public func array<T: Transformable>(_ keys: Path...) -> [T] {
        return value(for: keys).flatMap { try? T.deserialize(json: $0) }
    }
    
}

// MARK: - Dictionary

extension JSON {
    
    public var dictionary: [String : JSON] {
        guard case .dict(let dictionary) = self else { return [:] }
        return dictionary
    }

    public func dictionary(_ keys: Path...) -> [String : JSON] {
        return value(for: keys).dictionary
    }
    
    public func dictionary<T: Decodable>(_ keys: Path...) -> [String : T] {
        return Dictionary(pairs: value(for: keys).dictionary.flatMap {
            guard let value = try? T(json: $1) else { return nil }
            return ($0, value)
        })
    }
    
    public func dictionary<T: Transformable>(_ keys: Path...) -> [String : T] {
        return Dictionary(pairs: value(for: keys).dictionary.flatMap {
            guard let value = try? T.deserialize(json: $1) else { return nil }
            return ($0, value)
        })
    }
    
}

// MARK: - ExpressibleByNilLiteral

extension JSON: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension JSON: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self = .str(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .str(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .str(value)
    }
    
}

// MARK: - ExpressibleByFloatLiteral

extension JSON: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .d(value)
    }
    
}

// MARK: - ExpressibleByIntegerLiteral

extension JSON: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .i(value)
    }
    
}

// MARK: - ExpressibleByBooleanLiteral

extension JSON: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .b(value)
    }
    
}

// MARK: - ExpressibleByArrayLiteral

extension JSON: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Any...) {
        self = .arr((elements as [AnyObject]).map(JSON.parse))
    }
    
}

// MARK: - ExpressibleByDictionaryLiteral

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        var dictionary: [String : JSON] = [:]
        
        for (key, value) in elements {
            dictionary[key] = JSON.parse(object: value)
        }
        
        self = .dict(dictionary)
    }
    
}

// MARK: - Equatable

extension JSON: Equatable {
    
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.arr(let l), .arr(let r)):   return l == r
        case (.dict(let l), .dict(let r)): return l == r
        case (.str(let l), .str(let r)):   return l == r
        case (.i(let l), .i(let r)):       return l == r
        case (.d(let l), .d(let r)):       return l == r
        case (.b(let l), .b(let r)):       return l == r
        case (.null, .null):               return true
        default:                           return false
        }
    }
    
}
