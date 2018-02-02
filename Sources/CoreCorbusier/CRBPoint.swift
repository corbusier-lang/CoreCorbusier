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
