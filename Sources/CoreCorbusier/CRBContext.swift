
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
    
    public func anchor(with anchorKeyPath: CRBAnchorKeyPath, in object: CRBObject) throws -> CRBAnchor {
        guard object.isAnchorSupported(anchorName: anchorKeyPath) else {
            throw CRBContextMiss.noAnchor(object: object, anchorName: anchorKeyPath)
        }
        let placedObject = try object.placed()
        return placedObject.anchor(at: anchorKeyPath)!
    }
    
    public func anchor(with anchorKeyPath: CRBAnchorKeyPath, inObjectWith objectName: CRBObjectName) throws -> CRBAnchor {
        let object = try self.object(with: objectName)
        return try anchor(with: anchorKeyPath, in: object)
    }
    
    public func evaluate(expression: CRBExpression) throws -> CRBInstance {
        return try CRBExpressionEvaluator(context: self).evaluate(expression: expression)
    }
    
}

public enum CRBContextMiss : Error {
    
    case noInstance(CRBInstanceName)
    case wrongType(instanceName: CRBInstanceName, CRBInstance)
    case noObject(objectName: CRBObjectName)
    case noAnchor(object: CRBObject, anchorName: CRBAnchorKeyPath)
    
}

struct UnknownExpressionError : Error { }
