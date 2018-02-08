
import CoreCorbusier

public final class JaneContext {
    
    var statements: [CRBStatement] = []
    
    public func run(in context: inout CRBContext) throws {
        let compound = CRBStatement.ordered(statements)
//        var execution = CRBExecution(context: context)
//        try execution.execute(statement: compound)
        try context.execute(statement: compound)
    }
    
    public func add(_ statement: CRBStatement) {
        self.statements.append(statement)
    }
    
}

public func jane(in context: inout CRBContext, _ build: (JaneContext) -> ()) throws {
    let janeContext = JaneContext()
    build(janeContext)
    try janeContext.run(in: &context)
}

public func jane(in context: CRBContext, _ build: (JaneContext) -> ()) throws {
    var contextCopy = context
    try jane(in: &contextCopy, build)
}

public class JaneCommand {
    
    var context: JaneContext?
    
    func pass<OtherCommand : JaneCommand>(_ create: () -> OtherCommand) -> OtherCommand {
        let new = create()
        new.context = self.context
        return new
    }

}
