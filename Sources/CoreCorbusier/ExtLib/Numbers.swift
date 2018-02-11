//
//  Numbers.swift
//  CoreCorbusier
//
//  Created by Олег on 11.02.2018.
//

public enum ExtLib {
    
    public static func scope() -> CRBScope {
        return CRBScope(instances: [
            crbname("add"): ExtLibNumbers.add,
            crbname("negate"): ExtLibNumbers.negate,
            crbname("greater"): ExtLibNumbers.greater,
            crbname("identical"): identical
        ])
    }
    
    public static var identical: CRBExternalFunctionInstance {
        return CRBExternalFunctionInstance({ (instances) -> CRBInstance in
            var instances = instances
            let firstInstance = instances.removeFirst()
            for instance in instances {
                if instance !== firstInstance {
                    return CRBBoolInstance(false)
                }
            }
            return CRBBoolInstance(true)
        })
    }
    
}

public enum ExtLibNumbers {
    
    private static func pair(from instances: [CRBInstance]) throws -> (CRBNumberInstance, CRBNumberInstance) {
        let left = try downcast(instances[0], to: CRBNumberInstance.self)
        let right = try downcast(instances[1], to: CRBNumberInstance.self)
        return (left, right)
    }
    
    public static var add: CRBExternalFunctionInstance {
        return CRBExternalFunctionInstance({ (instances) -> CRBInstance in
            let (left, right) = try pair(from: instances)
            return CRBNumberInstance(left.value + right.value)
        })
    }
    
    public static var negate: CRBExternalFunctionInstance {
        return CRBExternalFunctionInstance({ (instances) -> CRBInstance in
            let num = try downcast(instances[0], to: CRBNumberInstance.self)
            return CRBNumberInstance(-num.value)
        })
    }
    
    public static var greater: CRBExternalFunctionInstance {
        return CRBExternalFunctionInstance({ (instances) -> CRBInstance in
            let (left, right) = try pair(from: instances)
            return CRBBoolInstance(left.value > right.value)
        })
    }
    
}
