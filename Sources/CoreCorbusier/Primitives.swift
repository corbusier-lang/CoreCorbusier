//
//  Primitives.swift
//  CoreCorbusier
//
//  Created by Олег on 05.02.2018.
//

public protocol CRBPlainInstance : CRBInstance { }
extension CRBPlainInstance {
    public func value(for propertyName: CRBPropertyName) -> CRBInstance? {
        return nil
    }
}

public final class CRBNumberInstance : CRBPlainInstance {
    
    public let value: CRBFloat
    
    public init(_ value: CRBFloat) {
        self.value = value
    }
    
}

public final class CRBPointInstance : CRBStaticInstance {
    
    public let point: CRBPoint
    
    public let values: [CRBPropertyName : CRBInstance]
    
    init(point: CRBPoint) {
        self.point = point
        self.values = [
            crbname("x"): CRBNumberInstance(point.x),
            crbname("y"): CRBNumberInstance(point.y),
        ]
    }
    
}
