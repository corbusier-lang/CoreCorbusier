
public struct CRBContext {
    
    public init() {
        
    }
    
    public var instances: [CRBInstanceName : CRBInstance] = [:]
    
    public func instance(with name: CRBInstanceName) throws -> CRBInstance {
        if let inst = instances[name] {
            return inst
        }
        throw CRBContextMiss.noInstance(name)
    }
    
    public func object(with name: CRBObjectName) throws -> CRBObject {
        let inst = try instance(with: crbname(name))
        if let obj = inst as? CRBObject {
            return obj
        }
        throw CRBContextMiss.wrongType(instanceName: crbname(name), inst)
    }
    
    public func anchor(with anchorName: CRBAnchorName, in object: CRBObject) throws -> CRBAnchor {
        guard object.isAnchorSupported(anchorName: anchorName) else {
            throw CRBContextMiss.noAnchor(object: object, anchorName: anchorName)
        }
        let placedObject = try object.placed()
        return placedObject.anchor(with: anchorName)!
    }
    
    public func anchor(with anchorName: CRBAnchorName, inObjectWith objectName: CRBObjectName) throws -> CRBAnchor {
        let object = try self.object(with: objectName)
        return try anchor(with: anchorName, in: object)
    }
    
    public func evaluate(expression: CRBExpression) throws -> CRBInstance {
        return try CRBExpressionEvaluator(context: self).evaluate(expression: expression)
    }
    
}

public struct CRBExpressionEvaluator {
    
    public let context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public func evaluate(expression: CRBExpression) throws -> CRBInstance {
        switch expression {
        case .placement(let expr):
            let fromAnchor = try self.anchor(for: expr.anchorPointToPlaceFrom)
            let placePoint = fromAnchor.placePoint(distance: expr.distance)
            let objectToPlace = try context.object(with: expr.toPlace.objectName)
            let anchorName = expr.toPlace.anchorName
            return CRBPlacementGuideInstance(objectToPlace: objectToPlace, anchorName: anchorName, pointToPlace: placePoint)
        case .instance(let name):
            return try context.instance(with: name)
        }
    }
    
    public func anchor(for anchorPoint: CRBPlaceExpression.AnchorPoint) throws -> CRBAnchor {
        switch anchorPoint {
        case .ofObject(let objectAnchor):
            return try context.anchor(with: objectAnchor.anchorName,
                                      inObjectWith: objectAnchor.objectName)
        }
    }
    
}

public struct CRBStatementExecutor {
    
    public init() { }
    
    private func evaluate<InstanceType : CRBInstance>(expression: CRBExpression,
                                                      to instanceType: InstanceType.Type,
                                                      in context: CRBContext) throws -> InstanceType {
        let result = try context.evaluate(expression: expression)
        return try downcast(result, to: instanceType)
    }
    
    public func execute(statement: CRBStatement, in context: inout CRBContext) throws {
        switch statement {
        case .place(let expression):
//            let fromAnchor = try self.anchor(for: expr.anchorPointToPlaceFrom)
//            let placePoint = fromAnchor.placePoint(distance: expr.distance)
//            let objectToPlace = try context.object(with: expr.toPlace.objectName)
//            let anchorName = expr.toPlace.anchorName
            let placement = try evaluate(expression: expression, to: CRBPlacementGuideInstance.self, in: context)
            guard placement.objectToPlace.isAnchorSupported(anchorName: placement.anchorName) else {
                throw CRBContextMiss.noAnchor(object: placement.objectToPlace, anchorName: placement.anchorName)
            }
            placement.objectToPlace.place(at: placement.pointToPlace, fromAnchorWith: placement.anchorName)
        case .assign(let instanceName, let expression):
            let instance = try context.evaluate(expression: expression)
            context.instances[instanceName] = instance
        case .unused(let expression):
            print("Unused expression: \(expression) ...")
            return
        }
    }
    
}

public struct CRBExecution {
    
    public var context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public mutating func execute(statement: CRBStatement) throws {
        let executor = CRBStatementExecutor()
        try executor.execute(statement: statement, in: &context)
    }
        
}

public enum CRBContextMiss : Error {
    
    case noInstance(CRBInstanceName)
    case wrongType(instanceName: CRBInstanceName, CRBInstance)
    case noObject(objectName: CRBObjectName)
    case noAnchor(object: CRBObject, anchorName: CRBAnchorName)
    
}

struct UnknownExpressionError : Error { }
