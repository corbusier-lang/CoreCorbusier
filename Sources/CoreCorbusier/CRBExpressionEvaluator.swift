//
//  CRBInstruction.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public struct CRBExpressionEvaluator {
    
    public let context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public func evaluate(expression: CRBExpression) throws -> CRBInstance {
        switch expression {
        case .placement(let expr):
            let fromAnchor = try self.anchor(for: expr.anchorPointToPlaceFrom)
            let placePoint = fromAnchor.anchor.placePoint(distance: expr.distance)
            let objectToPlace = try context.object(with: expr.toPlace.objectName)
            let anchorName = expr.toPlace.anchorKeyPath
            return CRBPlacementGuide(objectToPlace: objectToPlace, anchorName: anchorName, pointToPlace: placePoint)
        case .instance(let name):
            return try context.instance(with: name)
        case .subinstance(let name, let keypath):
            return try context.instance(with: name, keyPath: keypath)
        }
    }
    
    public func anchor(for anchorPoint: CRBPlaceExpression.AnchorPointRef) throws -> CRBAnchorInstance {
//        switch anchorPoint {
//        case .ofObject(let objectAnchor):
//            return try context.anchor(with: objectAnchor.anchorKeyPath,
//                                      inObjectWith: objectAnchor.objectName)
//        }
        let anchorInstance = try context.instance(with: anchorPoint.instanceName,
                                                  keyPath: anchorPoint.keyPath)
        return try downcast(anchorInstance, to: CRBAnchorInstance.self)
    }
    
}
