//
//  CRBInstance.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public protocol CRBInstance : AnyObject { }

public enum WrongTypeError : Error {
    case wrongType(expectedType: CRBInstance.Type, instance: CRBInstance)
}

internal func downcast<InstanceType : CRBInstance>(_ instance: CRBInstance, to instanceType: InstanceType.Type) throws -> InstanceType {
    if let downcasted = instance as? InstanceType {
        return downcasted
    }
    throw WrongTypeError.wrongType(expectedType: instanceType, instance: instance)
}

public typealias CRBInstanceName = Name<CRBInstance>

public final class CRBPlacementGuideInstance : CRBInstance {
    
    public let objectToPlace: CRBObject
    public let anchorName: CRBAnchorName
    public let pointToPlace: CRBPoint
    
    public init(objectToPlace : CRBObject, anchorName: CRBAnchorName, pointToPlace: CRBPoint) {
        self.objectToPlace = objectToPlace
        self.anchorName = anchorName
        self.pointToPlace = pointToPlace
    }
    
}
