//
//  CRBInstance.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public protocol CRBInstance : AnyObject { }

public typealias CRBInstanceName = Name<CRBInstance>

public final class CRBPlacementGuideInstance : CRBInstance {
    
    public let objectToPlace: CRBObject
    public let anchorKeyPath: CRBAnchorKeyPath
    public let pointToPlace: CRBPoint
    
    public init(objectToPlace : CRBObject, anchorName: CRBAnchorKeyPath, pointToPlace: CRBPoint) {
        self.objectToPlace = objectToPlace
        self.anchorKeyPath = anchorName
        self.pointToPlace = pointToPlace
    }
    
}

public enum WrongTypeError : Error {
    case wrongType(expectedType: CRBInstance.Type, instance: CRBInstance)
}

internal func downcast<InstanceType : CRBInstance>(_ instance: CRBInstance, to instanceType: InstanceType.Type) throws -> InstanceType {
    if let downcasted = instance as? InstanceType {
        return downcasted
    }
    throw WrongTypeError.wrongType(expectedType: instanceType, instance: instance)
}
