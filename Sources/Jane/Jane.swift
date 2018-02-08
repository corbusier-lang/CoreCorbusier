
import CoreCorbusier

public final class JaneContext {
    
    var statements: [CRBStatement] = []
    
    public func run(in context: inout CRBContext) throws {
        let compound = CRBStatement.ordered(statements)
        var execution = CRBExecution(context: context)
        try execution.execute(statement: compound)
        context = execution.context
    }
    
    public func add(_ statement: CRBStatement) {
        self.statements.append(statement)
    }
    
}

public func jane(in context: CRBContext, _ build: (JaneContext) -> ()) throws {
    let janeContext = JaneContext()
    build(janeContext)
    var contextCopy = context
    try janeContext.run(in: &contextCopy)
    dump(contextCopy)
}

public class JaneCommand {
    
    var context: JaneContext?
    
    func pass<OtherCommand : JaneCommand>(_ create: () -> OtherCommand) -> OtherCommand {
        let new = create()
        new.context = self.context
        return new
    }

}
