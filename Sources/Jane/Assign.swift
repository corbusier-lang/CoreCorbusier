//
//  Assign.swift
//  Jane
//
//  Created by Олег on 05.02.2018.
//

import CoreCorbusier

public protocol JaneExpression {
    
    func expression() -> CRBExpression
    
}

extension JaneExpression {
    
    public func call(_ args: JaneExpression...) -> JaneExpression {
        return JaneFunctionCall(functionCall: self, arguments: args)
    }
    
}

public final class JaneFunctionCall : JaneExpression {
    
    let functionCall: JaneExpression
    let arguments: [JaneExpression]
    
    init(functionCall: JaneExpression, arguments: [JaneExpression]) {
        self.functionCall = functionCall
        self.arguments = arguments
    }
    
    public func expression() -> CRBExpression {
        return CRBExpression.call(functionCall.expression(),
                                  arguments: arguments.map({ $0.expression() }))
    }
    
}

extension JaneContext {
    
    public func jlet(_ name: String) -> JaneLet {
        let new = JaneLet(name: name)
        new.context = self
        return new
    }
    
}

public final class JaneLet : JaneCommand {
    
    let name: String
    init(name: String) {
        self.name = name
    }
    
    public func equals(_ i: JaneExpression) {
        let instanceExpression = i.expression()
        let statement = CRBStatement.assign(crbname(self.name), instanceExpression)
        context?.add(statement)
    }
    
}

public func i(_ name: String) -> JaneInstanceRef {
    return JaneInstanceRef(name: crbname(name))
}

public func i(_ value: Double) -> JaneInstance {
    let num = CRBNumberInstance(CRBFloat(value))
    return JaneInstance(instance: num)
}

public final class JaneInstance : JaneExpression {
    
    let instance: CRBInstance
    
    public init(instance: CRBInstance) {
        self.instance = instance
    }
    
    public func expression() -> CRBExpression {
        return CRBExpression.instance(instance)
    }
    
}

public final class JaneInstanceRef : JaneExpression {
    
    let name: CRBInstanceName
    let keyPath: CRBKeyPath
    
    internal init(name: CRBInstanceName, keyPath: CRBKeyPath = []) {
        self.name = name
        self.keyPath = keyPath
    }
    
    public func at(_ key: String) -> JaneInstanceRef {
        var newKeyPath = keyPath
        newKeyPath.append(crbname(key))
        return JaneInstanceRef(name: self.name, keyPath: newKeyPath)
    }
    
    public func expression() -> CRBExpression {
        return CRBExpression.reference(self.name, self.keyPath)
    }
    
}
