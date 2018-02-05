//
//  CRBPlacementGuide.swift
//  CoreCorbusier
//
//  Created by Олег on 05.02.2018.
//

public protocol CRBPlacementGuideInstance : CRBInstance {
    
    var objectToPlace: CRBObject { get }
    var anchorKeyPath: CRBAnchorKeyPath { get }
    var pointToPlace: CRBPoint { get }
    
}

extension CRBPlacementGuideInstance {
    
    public func value(for propertyName: CRBPropertyName) -> CRBInstance? {
        switch propertyName {
        case "object":
            return objectToPlace
        default:
            return nil
        }
    }
    
}

public final class CRBPlacementGuide : CRBPlacementGuideInstance {
    
    public let objectToPlace: CRBObject
    public let anchorKeyPath: CRBAnchorKeyPath
    public let pointToPlace: CRBPoint
    
    public init(objectToPlace : CRBObject, anchorName: CRBAnchorKeyPath, pointToPlace: CRBPoint) {
        self.objectToPlace = objectToPlace
        self.anchorKeyPath = anchorName
        self.pointToPlace = pointToPlace
    }
    
}

