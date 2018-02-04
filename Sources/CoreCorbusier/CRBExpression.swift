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
        public let anchorName: CRBAnchorName
        
        public init(objectName: CRBObjectName, anchorName: CRBAnchorName) {
            self.objectName = objectName
            self.anchorName = anchorName
        }
    }
    
    public enum AnchorPoint {
        case ofObject(ObjectAnchor)
    }

}
