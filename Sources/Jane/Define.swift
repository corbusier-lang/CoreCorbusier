//
//  Define.swift
//  Jane
//
//  Created by Олег on 08.02.2018.
//

import CoreCorbusier

extension JaneContext {
    
    public var define: JaneDefine {
        let jd = JaneDefine()
        jd.context = self
        return jd
    }
    
    public func retur(_ expression: JaneExpression) {
        let cexpression = expression.expression()
        let statement = CRBStatement.return(cexpression)
        self.add(statement)
    }
    
}

public final class JaneDefine : JaneCommand {
    
    public func f(_ functionName: String) -> JaneFunctionName {
        return pass({ JaneFunctionName.init(functionName: crbname(functionName)) })
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
