//
//  Extensions.swift
//  Olympia
//
//  Created by Jonathan Landon on 2/29/16.
//

extension Dictionary {
    
    internal func map<T>(_ f: (Value) -> T) -> [Key : T] {
        var dictionary: [Key : T] = [:]
        
        for (key, value) in self {
            dictionary[key] = f(value)
        }
        
        return dictionary
    }
    
    internal init(pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }
    
}

extension UIColor {
    
    internal final var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    internal final var hexString: String {
        return String(format:"#%06x", hex)
    }
    
    internal final var hex: UInt32 {
        let rgba = self.rgba
        
        let red   = UInt32(rgba.r * 255) << 16
        let green = UInt32(rgba.g * 255) << 8
        let blue  = UInt32(rgba.b * 255)
        
        return red | green | blue
    }
    
}
