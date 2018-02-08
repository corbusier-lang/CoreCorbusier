
public struct CRBContext {
    
    public init(instances: [CRBInstanceName : CRBInstance] = [:]) {
        self.instances = instances
    }
    
    public var instances: [CRBInstanceName : CRBInstance]
    
    public func instance(with name: CRBInstanceName) throws -> CRBInstance {
        if let inst = instances[name] {
            return inst
        }
        throw CRBContextMiss.noInstance(name)
    }
    
    public func instance(with name: CRBInstanceName, keyPath: CRBKeyPath) throws -> CRBInstance {
        let inst = try self.instance(with: name)
        if let subinst = inst.value(for: keyPath) {
            return subinst
        } else {
            throw CRBContextMiss.noValue(keyPath, inst)
        }
    }
    
    public func object(with name: CRBObjectName) throws -> CRBObject {
        let inst = try instance(with: converted(name))
        if let obj = inst as? CRBObject {
            return obj
        }
        throw CRBContextMiss.wrongType(instanceName: converted(name), inst)
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
    
    public func evaluate<InstanceType : CRBInstance>(expression: CRBExpression, to instanceType: InstanceType.Type) throws -> InstanceType {
        return try CRBExpressionEvaluator(context: self).evaluate(expression: expression, to: instanceType)
    }
    
    public func merged(with parentContext: CRBContext) -> CRBContext {
        var newContext = parentContext
        for (instanceName, instance) in self.instances {
            newContext.instances[instanceName] = instance
        }
        return newContext
    }
    
}

public enum CRBContextMiss : Error {
    
    case noInstance(CRBInstanceName)
    case noValue(CRBKeyPath, CRBInstance)
    case wrongType(instanceName: CRBInstanceName, CRBInstance)
    case noObject(objectName: CRBObjectName)
    case noAnchor(object: CRBObject, anchorName: CRBAnchorKeyPath)
    
}

struct UnknownExpressionError : Error { }

extension CRBContext : Equatable {
    
    public static func == (lhs: CRBContext, rhs: CRBContext) -> Bool {
        guard lhs.instances.keys == rhs.instances.keys else {
            return false
        }
        for (key, value) in lhs.instances {
            if rhs.instances[key] !== value {
                return false
            }
        }
        return true
    }
    
}

