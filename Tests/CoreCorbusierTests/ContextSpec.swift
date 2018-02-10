//
//  ContextSpec.swift
//  CoreCorbusierTests
//
//  Created by Олег on 10.02.2018.
//

@testable import CoreCorbusier

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
    
}
