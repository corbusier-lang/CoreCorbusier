//
//  CRBInstance.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public enum _Property { }
public typealias CRBPropertyName = Name<_Property>

public protocol CRBInstance : AnyObject {
    
    func value(for propertyName: CRBPropertyName) -> CRBInstance?
    
}

public typealias CRBInstanceName = Name<CRBInstance>

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

