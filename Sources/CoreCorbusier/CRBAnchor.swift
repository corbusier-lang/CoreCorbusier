//
//  CRBAnchor.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public struct CRBAnchorName : RawRepresentable, Hashable {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}

public struct CRBAnchor {
    
    public var point: CRBPoint
    public var normalizedVector: CRBNormalizedVector
    
    public init(point: CRBPoint, normalizedVector: CRBNormalizedVector) {
        self.point = point
        self.normalizedVector = normalizedVector
    }
    
}
