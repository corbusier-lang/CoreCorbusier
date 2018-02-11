//
//  FunctionsSpec.swift
//  CoreCorbusierTests
//
//  Created by Олег on 11.02.2018.
//

import CoreCorbusier
import Jane

func testFunctions() {
    
    describe("corbusier function instances") {
        $0.it("returns void when no return is explicitly made") {
            let statement1 = statement(jane: { $0.let_("a").equals(5.0) })
            let function = CRBFunctionInstance.init(argumentNames: [], statements: [statement1])
            let result = try function.evaluate(in: CRBContext(), arguments: [])
            try expect(result.objectIdentifier()) == VoidInstance.shared.objectIdentifier()
        }
        $0.it("returns null when return null") {
            let statement1 = statement(jane: { $0.return_(null) })
            let function = CRBFunctionInstance.init(argumentNames: [], statements: [statement1])
            let result = try function.evaluate(in: CRBContext(), arguments: [])
            try expect(result.objectIdentifier()) == CRBNull.shared.objectIdentifier()
        }
    }
    
}
