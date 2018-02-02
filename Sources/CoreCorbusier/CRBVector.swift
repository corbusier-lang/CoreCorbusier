//
//  CRBVector.swift
//  CoreCorbusier
//
//  Created by Олег on 02.02.2018.
//

import CoreGraphics

public struct CRBVector {
    
    public var dx: CRBFloat
    public var dy: CRBFloat
    
    public init(dx: CRBFloat, dy: CRBFloat) {
        self.dx = dx
        self.dy = dy
    }
    
    public var length: CRBFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    public static var zero: CRBVector {
        return CRBVector(dx: 0, dy: 0)
    }
    
    public func normalized() -> CRBNormalizedVector {
        return CRBNormalizedVector(vector: self)
    }
    
    public func alreadyNormalized() -> CRBNormalizedVector {
        return CRBNormalizedVector(alreadyNormalizedVector: self)
    }
    
}

public struct CRBNormalizedVector {
    
    private var _vector: CRBVector
    
    public func asVector() -> CRBVector {
        return _vector
    }
    
    public var dx: CRBFloat {
        return _vector.dx
    }
    
    public var dy: CRBFloat {
        return _vector.dy
    }
    
    fileprivate init(alreadyNormalizedVector: CRBVector) {
        assert(alreadyNormalizedVector.length == 1)
        self._vector = alreadyNormalizedVector
    }
    
    fileprivate init(vector: CRBVector) {
        self._vector = CRBNormalizedVector.normalized(vector: vector)
        assert(_vector.length == 1)
    }
    
    private static func normalized(vector: CRBVector) -> CRBVector {
        let length = vector.length
        if length > 0 {
            return CRBVector(dx: vector.dx / length, dy: vector.dy / length)
        } else {
            return .zero
        }
    }
    
}
