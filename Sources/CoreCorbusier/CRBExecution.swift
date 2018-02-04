//
//  CRBExecution.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public struct CRBExecution {
    
    public var context: CRBContext
    
    public init(context: CRBContext) {
        self.context = context
    }
    
    public mutating func execute(statement: CRBStatement) throws {
        let executor = CRBStatementExecutor()
        try executor.execute(statement: statement, in: &context)
    }
    
}
