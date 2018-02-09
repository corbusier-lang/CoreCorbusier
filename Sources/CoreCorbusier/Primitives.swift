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

public final class CRBValueInstance<Value> : CRBPlainInstance {
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
}

public typealias CRBNumberInstance = CRBValueInstance<CRBFloat>
public typealias CRBBoolInstance = CRBValueInstance<Bool>

public final class VoidInstance : CRBPlainInstance {
    
    public static let shared = VoidInstance()
    
    private init() { }
    
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
