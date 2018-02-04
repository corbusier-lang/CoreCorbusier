
public struct CRBContext {
    
    public init() {
        
    }
    
    public var objectsMap: [CRBObjectName : CRBObject] = [:]
    
    public func object(with name: CRBObjectName) throws -> CRBObject {
        if let obj = objectsMap[name] {
            return obj
        }
        throw CRBContextMiss.noObject(objectName: name)
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
    
}

public struct CRBExpressionExecutor {
    
    public let context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public func execute(expression: CRBExpression) throws {
        switch expression {
        case .place(let placeExpression):
            let fromAnchor = try self.anchor(for: placeExpression.anchorPointToPlaceFrom)
            let placePoint = fromAnchor.placePoint(distance: placeExpression.distance)
            let objectToPlace = try context.object(with: placeExpression.toPlace.objectName)
            objectToPlace.place(at: placePoint, fromAnchorWith: placeExpression.toPlace.anchorName)
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

public struct CRBExecution {
    
    public var context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public mutating func execute(expression: CRBExpression) throws {
        let executor = CRBExpressionExecutor(context: context)
        try executor.execute(expression: expression)
    }
        
}

public enum CRBContextMiss : Error {
    
    case noObject(objectName: CRBObjectName)
    case noAnchor(object: CRBObject, anchorName: CRBAnchorName)
    
}

struct UnknownExpressionError : Error { }
