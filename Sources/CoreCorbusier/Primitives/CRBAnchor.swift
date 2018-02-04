//
//  CRBAnchor.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public typealias CRBAnchorName = Name<CRBAnchor>
public typealias CRBAnchorKeyPath = [CRBAnchorName]

public struct CRBAnchor : CRBAnchorEnvironment {
    
    let child: CRBAnchorEnvironment?
    
    public var point: CRBPoint
    public var normalizedVector: CRBNormalizedVector
    
    public init(point: CRBPoint, normalizedVector: CRBNormalizedVector, child: CRBAnchorEnvironment? = nil) {
        self.point = point
        self.normalizedVector = normalizedVector
        self.child = child
    }
    
    public func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        return child?.anchor(with: name)
    }
    
}

extension CRBAnchor {
    
    public func placePoint(distance: CRBFloat) -> CRBPoint {
        let distancedVector = self.normalizedVector.asVector().multiplied(byScalar: distance)
        return self.point.shifted(with: distancedVector)
    }
    
}
