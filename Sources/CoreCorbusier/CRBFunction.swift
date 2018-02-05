//
//  CRBFunction.swift
//  CoreCorbusier
//
//  Created by Олег on 05.02.2018.
//

public enum _Argument { }
public typealias CRBArgumentName = Name<_Argument>

public class CRBFunctionInstance : CRBPlainInstance {
    
    public let argumentNames: [CRBArgumentName]
    private let _function: (inout CRBContext) throws -> CRBInstance
    
    init(argumentNames: [CRBArgumentName],
         _ function: @escaping (inout CRBContext) throws -> CRBInstance) {
        self.argumentNames = argumentNames
        self._function = function
    }
    
    public func evaluate(outerScope: CRBContext, arguments: [CRBExpression]) throws -> CRBInstance {
        assert(argumentNames.count == arguments.count)
        let parameters = try arguments.map({ try outerScope.evaluate(expression: $0) })
        var functionScope = CRBContext()
        for (argName, parameter) in zip(argumentNames, parameters) {
            functionScope.instances[converted(argName)] = parameter
        }
        var mergedScope = functionScope.merged(with: outerScope)
        return try _function(&mergedScope)
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

//public final class CRBExternalFunctionInstance : CRBFunctionInstance {
//
//    init(_ function: @escaping ([CRBInstance]) throws -> CRBInstance) {
//        super.init(argumentNames: []) { (context) throws -> CRBInstance in
//            return try function()
//        }
//    }
//
//}
//
//let add = CRBExternalFunctionInstance { (instances) throws -> CRBInstance in
//    let a = try downcast(instances[0], to: CRBNumberInstance.self)
//    let b = try downcast(instances[1], to: CRBNumberInstance.self)
//    return CRBNumberInstance(a.value + b.value)
//}

