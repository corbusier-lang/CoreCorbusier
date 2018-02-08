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
    
    public func lett(_ name: String) -> JaneLet {
        let new = JaneLet(name: name)
        new.context = self
        return new
    }
    
    public func e(_ expression: JaneExpression) {
        let unused = CRBStatement.unused(expression.expression())
        add(unused)
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

extension Double : JaneExpression {
    
    public func expression() -> CRBExpression {
        return .instance(CRBNumberInstance.init(CRBFloat(self)))
    }
    
}

public protocol JaneInstanceRefProtocol : JaneExpression {
    
    var name: CRBInstanceName { get }
    var keyPath: CRBKeyPath { get }
    
}

extension JaneInstanceRefProtocol {
    
    public func at(_ key: String) -> JaneInstanceRef {
        var newKeyPath = keyPath
        newKeyPath.append(crbname(key))
        return JaneInstanceRef(name: self.name, keyPath: newKeyPath)
    }
    
    public func expression() -> CRBExpression {
        return CRBExpression.reference(self.name, self.keyPath)
    }
    
}

extension String : JaneInstanceRefProtocol {
    
    public var name: CRBInstanceName {
        return crbname(self)
    }
    
    public var keyPath: CRBKeyPath { return [] }
    
}

public final class JaneInstanceRef : JaneInstanceRefProtocol {
    
    public let name: CRBInstanceName
    public let keyPath: CRBKeyPath
    
    internal init(name: CRBInstanceName, keyPath: CRBKeyPath = []) {
        self.name = name
        self.keyPath = keyPath
    }
    
}
