//
//  Define.swift
//  Jane
//
//  Created by Олег on 08.02.2018.
//

import CoreCorbusier

public final class JaneVoid : JaneExpression {
    public func expression() -> CRBExpression {
        return .instance(VoidInstance.shared)
    }
}

public final class JaneNull : JaneExpression {
    public func expression() -> CRBExpression {
        return .instance(CRBNull.shared)
    }
}

public let void = JaneVoid()
public let null = JaneNull()

extension JaneContext {
    
    public func def(_ functionName: String) -> JaneFunctionName {
        let jfn = JaneFunctionName(functionName: crbname(functionName))
        jfn.context = self
        return jfn
    }
    
    public func return_(_ expression: JaneExpression) {
        let cexpression = expression.expression()
        let statement = CRBStatement.return(cexpression)
        self.add(statement)
    }
    
}

public final class JaneFunctionName : JaneCommand {
    
    let functionName: CRBFunctionName
    init(functionName: CRBFunctionName) {
        self.functionName = functionName
    }
    
    public func args(_ argumentNames: String...) -> JaneFunctionWithArgs {
        return pass({ JaneFunctionWithArgs.init(functionName: self.functionName, args: argumentNames.map(crbname)) })
    }
    
}

public final class JaneFunctionWithArgs : JaneCommand {
    
    let functionName: CRBFunctionName
    let args: [CRBArgumentName]
    
    init(functionName: CRBFunctionName, args: [CRBArgumentName]) {
        self.functionName = functionName
        self.args = args
    }
    
    public func build(_ build: (JaneContext) -> ()) {
        let functionContext = JaneContext()
        build(functionContext)
        let statements = functionContext.statements
        let defineStatement = CRBStatement.define(functionName, args, statements)
        self.context?.add(defineStatement)
    }
    
}
