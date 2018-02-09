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
            let instance = try context.evaluate(expression: expression)
            if instance !== VoidInstance.shared {
                print("Unused expression: \(expression) ...")
            }
        case .define(let functionName, let argumentNames, let statements):
            let function = CRBFunctionInstance(argumentNames: argumentNames, statements: statements)
            context.instances[converted(functionName)] = function
        case .return(_):
            fatalError("return is unsupported on a top-level")
        case .conditioned(let `if`, let `do`, let `else`):
            let bool = try context.evaluate(expression: `if`, to: CRBBoolInstance.self)
            if bool.value == true {
                try execute(statement: `do`, in: &context)
            } else {
                try execute(statement: `else`, in: &context)
            }
        }
    }
    
}
