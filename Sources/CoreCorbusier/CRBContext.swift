
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

public struct CRBStatementExecutor {
    
    public let context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public func execute(statement: CRBStatement) throws {
        switch statement {
        case .place(let placement):
            switch placement {
            case .expression(let expr):
                let fromAnchor = try self.anchor(for: expr.anchorPointToPlaceFrom)
                let placePoint = fromAnchor.placePoint(distance: expr.distance)
                let objectToPlace = try context.object(with: expr.toPlace.objectName)
                let anchorName = expr.toPlace.anchorName
                guard objectToPlace.isAnchorSupported(anchorName: anchorName) else {
                    throw CRBContextMiss.noAnchor(object: objectToPlace, anchorName: anchorName)
                }
                objectToPlace.place(at: placePoint, fromAnchorWith: expr.toPlace.anchorName)
            }
        case .expression(let expression):
            print("Unused expression: \(expression) ...")
            return
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
    
    public mutating func execute(statement: CRBStatement) throws {
        let executor = CRBStatementExecutor(context: context)
        try executor.execute(statement: statement)
    }
        
}

public enum CRBContextMiss : Error {
    
    case noObject(objectName: CRBObjectName)
    case noAnchor(object: CRBObject, anchorName: CRBAnchorName)
    
}

struct UnknownExpressionError : Error { }
