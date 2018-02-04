//
//  CRBExpression.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public enum CRBExpression {
    
    case placement(CRBPlaceExpression)
    case instance(CRBInstanceName)
    
} 

public struct CRBPlaceExpression {
    
    public let toPlace: ObjectAnchor
    public let distance: CRBFloat
    public let anchorPointToPlaceFrom: AnchorPoint
    
    public init(toPlace: ObjectAnchor, distance: CRBFloat, anchorPointToPlaceFrom: AnchorPoint) {
        self.toPlace = toPlace
        self.distance = distance
        self.anchorPointToPlaceFrom = anchorPointToPlaceFrom
    }
    
    public struct ObjectAnchor {
        public let objectName: CRBObjectName
        public let anchorKeyPath: CRBAnchorKeyPath
        
        public init(objectName: CRBObjectName, anchorKeyPath: CRBAnchorKeyPath) {
            self.objectName = objectName
            self.anchorKeyPath = anchorKeyPath
        }
    }
    
    public enum AnchorPoint {
        case ofObject(ObjectAnchor)
    }

}
