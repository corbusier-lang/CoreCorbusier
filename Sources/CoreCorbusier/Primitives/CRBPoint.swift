//
//  CRBPoint.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public struct CRBPoint {
    
    public var x: CRBFloat
    public var y: CRBFloat
    
    public init(x: CRBFloat, y: CRBFloat) {
        self.x = x
        self.y = y
    }
    
    public func shifted(with vector: CRBVector) -> CRBPoint {
        return CRBPoint(x: self.x + vector.dx, y: self.y + vector.dy)
    }
    
    public static func between(_ p1: CRBPoint, _ p2: CRBPoint, multiplier: CRBFloat) -> CRBPoint {
        return CRBPoint(x: (p1.x + p2.x) * multiplier, y: (p1.y + p2.y) * multiplier)
    }
    
}

extension CRBPoint : Hashable {
    
    public var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
    
    public static func ==(lhs: CRBPoint, rhs: CRBPoint) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }
    
}

extension CRBPoint {
    
    public static var zero: CRBPoint {
        return CRBPoint(x: 0, y: 0)
    }
    
}
