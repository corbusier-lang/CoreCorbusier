//
//  ContextSpec.swift
//  CoreCorbusierTests
//
//  Created by Олег on 10.02.2018.
//

@testable import CoreCorbusier
import Foundation

func testContext() {
    
    describe("scope") {
        $0.it("has instances property") {
            let instances: [CRBInstanceName : CRBInstance] = [
                crbname("a"): CRBNumberInstance(5.0)
            ]
            let scope = CRBScope(instances: instances)
            let otherScope = CRBScope(instances: instances)
            try expect(otherScope) == scope
        }
        $0.it("can modify instances") {
            let instances: [CRBInstanceName : CRBInstance] = [
                crbname("a"): CRBNumberInstance(5.0)
            ]
            var scope1 = CRBScope(instances: instances)
            let num = CRBNumberInstance(10.0)
            scope1.instances[crbname("b")] = num
            try expect(scope1.instances[crbname("b")]!.objectIdentifier()) == num.objectIdentifier()
        }
    }
    
    describe("context") {
        $0.it("holds a stack of scopes") {
            let scope1 = CRBScope(instances: [crbname("a"): CRBNumberInstance(10.0)])
            let scope2 = CRBScope(instances: [crbname("b"): CRBNumberInstance(15.0)])
            let context = CRBContext(scopes: Stack([scope1, scope2]))
            try expect(context.scopes.array) == [scope1, scope2]
        }
        $0.it("have a nil returningValue on creation") {
            let context = CRBContext()
            try expect(context.returningValue).to.beNil()
        }
        $0.it("can change returning value") {
            var context = CRBContext()
            let inst = CRBNumberInstance(10.0)
            context.returningValue = inst
            try expect(context.returningValue!.objectIdentifier()) == inst.objectIdentifier()
        }
        $0.it("holds a reference to a top scope in a stack") {
            let scope1 = CRBScope(instances: [crbname("a"): CRBNumberInstance(10.0)])
            let scope2 = CRBScope(instances: [crbname("b"): CRBNumberInstance(15.0)])
            var context = CRBContext(scopes: Stack([scope1, scope2]))
            try expect(context.currentScope) == scope2
            context.currentScope = scope1
            try expect(context.currentScope) == scope1
            try expect(context.scopes.array) == [scope1, scope1]
        }
        
        $0.describe("instance with name method") {
            $0.it("returns an instance if present") {
                var context = CRBContext()
                let num = CRBNumberInstance(10.0)
                context.currentScope.instances[crbname("a")] = num
                let inst = try context.instance(with: crbname("a"))
                try expect(inst.objectIdentifier()) == num.objectIdentifier()
            }
            $0.it("throws if there is no value") {
                let context = CRBContext()
                try expect(try context.instance(with: crbname("none"))).toThrow()
            }
            $0.it("returns an instance evaluated to its key path if present") {
                var context = CRBContext()
                let num = CRBNumberInstance(10.0)
                let deep = CRBBlockInstance({ (name) -> CRBInstance? in
                    if name.rawValue == "a" {
                        return CRBBlockInstance.init({ (name) -> CRBInstance? in
                            if name.rawValue == "b" {
                                return num
                            }
                            return nil
                        })
                    }
                    return nil
                })
                context.currentScope.instances[crbname("deep")] = deep
                let inst = try context.instance(with: crbname("deep"), keyPath: crbpath("a", "b"))
                try expect(inst.objectIdentifier()) == num.objectIdentifier()
            }
            $0.it("throws if cannot access the right key path") {
                let context = CRBContext(instances: [
                    crbname("num"): CRBNumberInstance(10.0)
                ])
                try expect(try context.instance(with: crbname("num"), keyPath: crbpath("a"))).toThrow()
            }
        }
        
        $0.describe("object with name method") {
            $0.it("returns an object if present") {
                let obj = CGArea(size: CGSize.init(width: 10, height: 10))
                let context = CRBContext(instances: [crbname("obj"): obj])
                let back = try context.object(with: crbname("obj"))
                try expect(obj.objectIdentifier()) == back.objectIdentifier()
            }
            $0.it("throws if there is no object") {
                let context = CRBContext()
                try expect(try context.object(with: crbname("obj"))).toThrow()
            }
            $0.it("throws if value for name is not an object") {
                let context = CRBContext(instances: [crbname("bool"): CRBBoolInstance(true)])
                try expect(try context.object(with: crbname("bool"))).toThrow()
            }
        }
    }
    
}
