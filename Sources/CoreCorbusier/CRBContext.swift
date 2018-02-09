
public struct Stack<T> {
    fileprivate var array = [T]()
    
    public init(_ array: [T] = []) {
        self.array = array
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    @discardableResult
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public var top: T? {
        return array.last
    }
}

public struct CRBScope {
    
    public var instances: [CRBInstanceName : CRBInstance]
    
    public init(instances: [CRBInstanceName : CRBInstance] = [:]) {
        self.instances = instances
    }
    
}

public struct CRBContext {
    
    public init(instances: [CRBInstanceName : CRBInstance] = [:]) {
        let scope = CRBScope(instances: instances)
        self.init(scopes: Stack([scope]))
    }
    
    public init(scopes: Stack<CRBScope>) {
        self.scopes = scopes
    }
    
    public var scopes: Stack<CRBScope>
    public var currentScope: CRBScope {
        get { return scopes.top! }
        set { scopes.pop(); scopes.push(newValue) }
    }
    
    private func instance(with name: CRBInstanceName, in scope: CRBScope) -> CRBInstance? {
        return scope.instances[name]
    }
    
    private func instance(with name: CRBInstanceName, in stack: Stack<CRBScope>) throws -> CRBInstance {
        var copiedStack = stack
        if let topScope = copiedStack.pop() {
            if let inThis = instance(with: name, in: topScope) {
                return inThis
            }
            return try instance(with: name, in: copiedStack)
        }
        throw CRBContextMiss.noInstance(name)
    }
    
    public func instance(with name: CRBInstanceName) throws -> CRBInstance {
        return try instance(with: name, in: scopes)
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
    
    private let executor = CRBStatementExecutor()
    public mutating func execute(statement: CRBStatement) throws {
        try executor.execute(statement: statement, in: &self)
    }
    
    public func evaluate(expression: CRBExpression) throws -> CRBInstance {
        return try CRBExpressionEvaluator(context: self).evaluate(expression: expression)
    }
    
    public func evaluate<InstanceType : CRBInstance>(expression: CRBExpression, to instanceType: InstanceType.Type) throws -> InstanceType {
        return try CRBExpressionEvaluator(context: self).evaluate(expression: expression, to: instanceType)
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

extension CRBScope : Equatable {
    
    public static func == (lhs: CRBScope, rhs: CRBScope) -> Bool {
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

extension CRBContext : Equatable {
    
    public static func == (lhs: CRBContext, rhs: CRBContext) -> Bool {
        return lhs.scopes.array == rhs.scopes.array
    }
    
}
