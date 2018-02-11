//
//  If.swift
//  Jane
//
//  Created by Олег on 09.02.2018.
//

import CoreCorbusier

extension JaneContext {
    
    public func if_(_ condition: JaneExpression) -> JaneCondition {
        let janeIf = JaneCondition(condition: condition)
        janeIf.context = self
        return janeIf
    }
    
}

public final class JaneCondition : JaneCommand {
    
    let condition: JaneExpression
    init(condition: JaneExpression) {
        self.condition = condition
    }
    
    public func do_(_ block: @escaping (JaneContext) -> ()) {
        let newContext = JaneContext()
        let statements = newContext.statements
        let ifStatement = CRBStatement.conditioned(if: condition.expression(), do: .ordered(statements), else: .ordered([]))
        context?.add(ifStatement)
    }
    
    public func do_(_ block: @escaping (JaneContext) -> ()) -> JaneIf {
        return pass({ JaneIf.init(condition: self, doBlock: block) })
    }
    
}

public final class JaneIf : JaneCommand {
    
    let condition: JaneCondition
    let doBlock: (JaneContext) -> ()
    init(condition: JaneCondition, doBlock: @escaping (JaneContext) -> ()) {
        self.condition = condition
        self.doBlock = doBlock
    }
    
    func statements(with block: (JaneContext) -> ()) -> [CRBStatement] {
        let new = JaneContext()
        block(new)
        return new.statements
    }
    
    public func else_(_ elseBlock: @escaping (JaneContext) -> ()) {
        let doStatements = statements(with: doBlock)
        let elseStatements = statements(with: elseBlock)
        let ifStatement = CRBStatement.conditioned(if: condition.condition.expression(), do: .ordered(doStatements), else: .ordered(elseStatements))
        context?.add(ifStatement)
    }
    
}
