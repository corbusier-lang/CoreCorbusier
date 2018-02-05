//
//  CRBInstance.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public enum _Property { }
public typealias CRBInstanceName = Name<CRBInstance>
public typealias CRBPropertyName = Name<_Property>
public typealias CRBKeyPath = [CRBPropertyName]

public protocol CRBInstance : AnyObject {
    
    func value(for propertyName: CRBPropertyName) -> CRBInstance?
    
}

extension CRBInstance {
    
    public func value(for keyPath: CRBKeyPath) -> CRBInstance? {
        var current: CRBInstance = self
        for name in keyPath {
            if let deeper = current.value(for: name) {
                current = deeper
            } else {
                return nil
            }
        }
        return current
    }
    
}

public final class CRBBlockInstance : CRBInstance {
    
    private let block: (CRBPropertyName) -> CRBInstance?
    
    public init(_ block: @escaping (CRBPropertyName) -> CRBInstance?) {
        self.block = block
    }
    
    public func value(for propertyName: CRBPropertyName) -> CRBInstance? {
        return block(propertyName)
    }
    
}
public enum WrongTypeError : Error {
    case wrongType(instance: CRBInstance)
}

internal func downcast<InstanceType : CRBInstance>(_ instance: CRBInstance, to instanceType: InstanceType.Type) throws -> InstanceType {
    return try downcast(instance)
}

internal func downcast<InstanceType : CRBInstance>(_ instance: CRBInstance) throws -> InstanceType {
    if let downcasted = instance as? InstanceType {
        return downcasted
    }
    throw WrongTypeError.wrongType(instance: instance)
}

