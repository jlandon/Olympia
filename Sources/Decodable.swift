//
//  Decodable.swift
//  Olympia
//
//  Created by Jonathan Landon on 2/29/16.
//

public protocol Decodable {
    init(json: JSON) throws
}

extension Decodable {
    
    public static func decode(_ json: JSON) -> Self? {
        do {
            return try self.init(json: json)
        }
        catch let error as JSON.Error {
            #if DEBUG
                print(error)
            #endif
        }
        catch let error {
            #if DEBUG
                print(error)
            #endif
        }
        
        return nil
    }
    
    public func serialize() -> JSON {
    
        func inspect(_ mirror: Mirror) -> [String : AnyObject] {
            
            var mappings: [String : AnyObject] = [:]
            
            if let parentMirror = mirror.superclassMirror, !parentMirror.children.isEmpty {
                inspect(parentMirror).forEach { mappings.updateValue($0.1, forKey: $0.0) }
            }
            
            let keys = mirror.children.flatMap { $0.label }
            let values: [AnyObject] = mirror.children.flatMap {
                let value = $0.value
                let mirror = Mirror(reflecting: value)
                let optionalValue = mirror.descendant("some")
                
                // value is non-optional and conforms to AnyObject
                let nonOptional = JSON(object: value)?.unparse()
                
                // value is optional and conforms to AnyObject
                let optional = JSON(object: optionalValue)?.unparse()
                
                // value is non-optional and is Transformable
                let transformable = (value as? Transformable)?.serialize().rawValue
                
                // value is optional and is Transformable
                let optionalTransformable = (optionalValue as? Transformable)?.serialize().rawValue
                
                // value is non-optional and is Decodable
                let decodable = (value as? Decodable)?.serialize().rawValue
                
                // value is optional and is Decodable
                let optionalDecodable = (optionalValue as? Decodable)?.serialize().rawValue
                
                return nonOptional ??
                       optional ??
                       decodable ??
                       optionalDecodable ??
                       transformable ??
                       optionalTransformable ??
                       NSNull()
            }
            
            zip(keys, values).forEach { mappings.updateValue($1, forKey: $0) }
            
            return mappings
        }
        
        let mirror = Mirror(reflecting: self)
        let dictionary = inspect(mirror)
        
        return JSON.parse(object: dictionary)
    }
    
}

// MARK: - String

extension String: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .str(let string):
            self = string
        default:
            throw JSON.Error.inconvertible(value: json, to: String.self)
        }
    }
    
}

// MARK: - Int

extension Int: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .i(let int):
            self = int
        case .d(let double):
            self = Int(double)
        default:
            throw JSON.Error.inconvertible(value: json, to: Int.self)
        }
    }
    
}

// MARK: - Double

extension Double: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .i(let int):
            self = Double(int)
        case .d(let double):
            self = double
        default:
            throw JSON.Error.inconvertible(value: json, to: Double.self)
        }
    }
    
}

// MARK: - Bool

extension Bool: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .i(let int):
            self = Bool(NSNumber(value: int))
        case .str(let string):
            switch string.lowercased() {
            case "true":
                self = true
            case "false":
                self = false
            default:
                throw JSON.Error.inconvertible(value: json, to: Bool.self)
            }
        case .b(let bool):
            self = bool
        default:
            throw JSON.Error.inconvertible(value: json, to: Bool.self)
        }
    }
    
}

// MARK: - Float

extension Float: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .i(let int):
            self = Float(int)
        case .d(let double):
            self = Float(double)
        default:
            throw JSON.Error.inconvertible(value: json, to: Float.self)
        }
    }
    
}

// MARK: - UInt

extension UInt: Decodable {
    
    public init(json: JSON) throws {
        switch json {
        case .i(let int):
            self = UInt(abs(int))
        case .d(let double):
            self = UInt(abs(double))
        default:
            throw JSON.Error.inconvertible(value: json, to: UInt.self)
        }
    }
    
}
