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
            let distance = try evaluate(expression: expr.distance, to: CRBNumberInstance.self)
            let placePoint = fromAnchor.anchor.placePoint(distance: distance.value)
            let objectToPlace = try context.object(with: expr.toPlace.objectName)
            let anchorName = expr.toPlace.anchorKeyPath
            return CRBPlacementGuide(objectToPlace: objectToPlace, anchorName: anchorName, pointToPlace: placePoint)
        case .instance(let instance):
            return instance
        case .reference(let name, let keypath):
            return try context.instance(with: name, keyPath: keypath)
        case .call(let functionExpression, let arguments):
            let function = try evaluate(expression: functionExpression, to: CRBFunction.self)
            return try function.evaluate(outerScope: context, arguments: arguments)
        }
    }
    
    public func evaluate<InstanceType : CRBInstance>(expression: CRBExpression,
                                                     to instanceType: InstanceType.Type) throws -> InstanceType {
        let result = try context.evaluate(expression: expression)
        return try downcast(result, to: instanceType)
    }
    
    public func anchor(for anchorExpression: CRBExpression) throws -> CRBAnchorInstance {
        //        switch anchorPoint {
        //        case .ofObject(let objectAnchor):
        //            return try context.anchor(with: objectAnchor.anchorKeyPath,
        //                                      inObjectWith: objectAnchor.objectName)
        //        }
//        let anchorInstance = try evaluate(expression: anchorExpression)
//        return try downcast(anchorInstance, to: CRBAnchorInstance.self)
        return try evaluate(expression: anchorExpression, to: CRBAnchorInstance.self)
    }
    
}
