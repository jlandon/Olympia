//
//  Path.swift
//  Olympia
//
//  Created by Jonathan Landon on 5/22/16.
//

import Foundation

public protocol Path {
    func value(in dictionary: [String : JSON]) throws -> JSON
    func value(in array: [JSON]) throws -> JSON
}

extension Path {
    
    public func value(in dictionary: [String : JSON]) throws -> JSON {
        throw JSON.Error.invalidSubscript(type: type(of: self), value: self)
    }
    
    public func value(in array: [JSON]) throws -> JSON {
        throw JSON.Error.invalidSubscript(type: type(of: self), value: self)
    }
    
}

extension String: Path {
    
    public func value(in dictionary: [String : JSON]) throws -> JSON {
        guard let json = dictionary[self] else { throw JSON.Error.missing(key: self) }
        return json
    }
    
}

extension Int: Path {
    
    public func value(in array: [JSON]) throws -> JSON {
        guard array.indices.contains(self) else { throw JSON.Error.outOfBounds(index: self) }
        return array[self]
    }
    
}
