//
//  Transformable.swift
//  Olympia
//
//  Created by Jonathan Landon on 5/27/16.
//

import Foundation

public protocol Transformable {
    static func deserialize(json: JSON) throws -> Self
    func serialize() -> JSON
}

extension Transformable where Self: RawRepresentable, Self.RawValue == String {
    
    public static func deserialize(json: JSON) throws -> Self {
        guard
            let string = json.string,
            let value = Self(rawValue: string)
        else { throw JSON.Error.inconvertible(value: json, to: Self.self) }
        
        return value
    }
    
    public func serialize() -> JSON {
        return .str(rawValue)
    }
    
}

extension Transformable where Self: RawRepresentable, Self.RawValue == Int {
    
    public static func deserialize(json: JSON) throws -> Self {
        guard
            let int = json.int,
            let value = Self(rawValue: int)
        else { throw JSON.Error.inconvertible(value: json, to: Self.self) }
        
        return value
    }
    
    public func serialize() -> JSON {
        return .i(rawValue)
    }
    
}

extension CharacterSet {
    
    fileprivate static let url = CharacterSet().union(.urlFragmentAllowed)
                                               .union(.urlHostAllowed)
                                               .union(.urlPasswordAllowed)
                                               .union(.urlQueryAllowed)
                                               .union(.urlUserAllowed)
                                               .union(.urlPathAllowed)
    
}

extension URL: Transformable {
    
    public static func deserialize(json: JSON) throws -> URL {
        guard
            let string = json.string?.addingPercentEncoding(withAllowedCharacters: .url),
            let url = self.init(string: string)
        else { throw JSON.Error.inconvertible(value: json, to: URL.self) }
        
        return url
    }
    
    public func serialize() -> JSON {
        return JSON.str(absoluteString)
    }
    
}

extension UIColor: Transformable {
    
    public static func deserialize(json: JSON) throws -> Self {
        guard let string = json.string else { throw JSON.Error.inconvertible(value: json, to: UIColor.self) }
        
        var hexString = string
        if hexString.hasPrefix("#") {
            hexString = hexString.substring(from: hexString.index(after: hexString.startIndex))
        }
        
        let scanner = Scanner(string: hexString)
        var hex: UInt32 = 0
        scanner.scanHexInt32(&hex)
        
        let r = CGFloat((hex >> 16) & 0xFF)
        let g = CGFloat((hex >> 8) & 0xFF)
        let b = CGFloat(hex & 0xFF)
        
        return self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    public func serialize() -> JSON {
        return .str(hexString)
    }
    
}
