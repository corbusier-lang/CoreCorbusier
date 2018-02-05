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
    public let anchorPointToPlaceFrom: AnchorPointRef
    
    public init(toPlace: ObjectAnchor, distance: CRBFloat, anchorPointToPlaceFrom: AnchorPointRef) {
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
    
    public struct AnchorPointRef {
        public let instanceName: CRBInstanceName
        public let keyPath: CRBKeyPath
        
        public init(instanceName: CRBInstanceName, keyPath: CRBKeyPath) {
            self.instanceName = instanceName
            self.keyPath = keyPath
        }
    }
    
}
