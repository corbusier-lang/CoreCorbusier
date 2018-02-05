//
//  CRBExpression.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public indirect enum CRBExpression {
    
    case placement(CRBPlaceExpression)
    case instance(CRBInstance)
    case reference(CRBInstanceName, CRBKeyPath)
    case call(CRBExpression, arguments: [CRBExpression])
    
} 

public struct CRBPlaceExpression {
    
    public let toPlace: ObjectAnchor
    public let distance: CRBExpression
    public let anchorPointToPlaceFrom: CRBExpression
    
    public init(toPlace: ObjectAnchor, distance: CRBExpression, anchorPointToPlaceFrom: CRBExpression) {
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
    
}
