//
//  CRBStatementExecutor.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public struct CRBStatementExecutor {
    
    public init() { }
        
    public func execute(statement: CRBStatement, in context: inout CRBContext) throws {
        switch statement {
        case .place(let expression):
            let placement = try context.evaluate(expression: expression, to: CRBPlacementGuide.self)
            guard placement.objectToPlace.isAnchorSupported(anchorName: placement.anchorKeyPath) else {
                throw CRBContextMiss.noAnchor(object: placement.objectToPlace, anchorName: placement.anchorKeyPath)
            }
            placement.objectToPlace.place(at: placement.pointToPlace, fromAnchorWith: placement.anchorKeyPath)
        case .assign(let instanceName, let expression):
            let instance = try context.evaluate(expression: expression)
            context.instances[instanceName] = instance
        case .ordered(let statements):
            try statements.forEach { try self.execute(statement: $0, in: &context) }
        case .unused(let expression):
            print("Unused expression: \(expression) ...")
            return
        }
    }
    
}
