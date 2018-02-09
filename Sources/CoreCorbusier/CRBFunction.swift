//
//  CRBFunction.swift
//  CoreCorbusier
//
//  Created by Олег on 05.02.2018.
//

public enum _Argument { }
public typealias CRBArgumentName = Name<_Argument>
public typealias CRBFunctionName = Name<CRBFunction>

public class CRBFunction : CRBPlainInstance {
    
    struct Unimplemented : Error { }
    
    public func evaluate(in context: CRBContext, arguments: [CRBExpression]) throws -> CRBInstance {
        throw Unimplemented()
    }
    
    struct NoReturn : Error { }
    
}

public class CRBFunctionInstance : CRBFunction {
    
    public let argumentNames: [CRBArgumentName]
    private let _function: (inout CRBContext) throws -> CRBInstance
    
    public init(argumentNames: [CRBArgumentName],
         _ function: @escaping (inout CRBContext) throws -> CRBInstance) {
        self.argumentNames = argumentNames
        self._function = function
    }
    
    public convenience init(argumentNames: [CRBArgumentName],
                            statements: [CRBStatement]) {
        self.init(argumentNames: argumentNames) { (context) -> CRBInstance in
            let ordered = CRBStatement.ordered(statements)
            try context.execute(statement: ordered)
            if let returning = context.returningValue {
                return returning
            }
            throw NoReturn()
        }
    }
    
    public override func evaluate(in context: CRBContext, arguments: [CRBExpression]) throws -> CRBInstance {
        assert(argumentNames.count == arguments.count)
        let parameters = try arguments.map({ try context.evaluate(expression: $0) })
        var functionScope = CRBScope()
        for (argName, parameter) in zip(argumentNames, parameters) {
            functionScope.instances[converted(argName)] = parameter
        }
        var contextCopy = context
        contextCopy.scopes.push(functionScope)
        let result = try _function(&contextCopy)
        return result
    }
    
    public static func add() -> CRBFunctionInstance {
        return CRBFunctionInstance(argumentNames: [crbname("a"), crbname("b")], { (context) -> CRBInstance in
            let ia = try context.instance(with: crbname("a"))
            let a = try downcast(ia, to: CRBNumberInstance.self)
            let ib = try context.instance(with: crbname("b"))
            let b = try downcast(ib, to: CRBNumberInstance.self)
            return CRBNumberInstance(a.value + b.value)
        })
    }
    
}

public final class CRBExternalFunctionInstance : CRBFunction {
    
    private let _function: ([CRBInstance]) throws -> CRBInstance
    
    public init(_ function: @escaping ([CRBInstance]) throws -> CRBInstance) {
        self._function = function
    }
    
    public override func evaluate(in context: CRBContext, arguments: [CRBExpression]) throws -> CRBInstance {
        let parameters = try arguments.map({ try context.evaluate(expression: $0) })
        return try _function(parameters)
    }
    
    public static func print() -> CRBExternalFunctionInstance {
        return CRBExternalFunctionInstance { instances in
            for instance in instances {
                dump(instance)
            }
            return VoidInstance.shared
        }
    }
    
}
