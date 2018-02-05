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

public final class NumberInstance : CRBPlainInstance {
    
    public let value: CRBFloat
    
    init(value: CRBFloat) {
        self.value = value
    }
    
}

public final class CRBPointInstance : CRBInstance {
    
    public let point: CRBPoint
    
    init(point: CRBPoint) {
        self.point = point
    }
    
    public func value(for propertyName: CRBPropertyName) -> CRBInstance? {
        switch propertyName {
        case "x":
            return NumberInstance(value: point.x)
        case "y":
            return NumberInstance(value: point.y)
        default:
            return nil
        }
    }
    
}
