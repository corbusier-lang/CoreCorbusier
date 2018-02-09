//
//  ExpressionEvaluatorSpec.swift
//  CoreCorbusierTests
//
//  Created by Олег on 08.02.2018.
//

import Foundation
import Jane
@testable import CoreCorbusier

func testExpressionEvaluator() {
    
    let rectObj = CGArea(rect: .init(x: 10, y: 10, width: 50, height: 50))
    let sizeObj = CGArea(size: .init(width: 40, height: 40))
    let context = CRBContext(instances: [
            crbname("rect"): rectObj,
            crbname("size"): sizeObj
        ])
    let evaluator = CRBExpressionEvaluator(context: context)
    
    describe("expression evaluator") {
        $0.it("copies a context") {
            try expect(evaluator.context) == context
        }
    }
    
    describe("reference expression") {
        $0.it("returns an instance if present") {
            let expr = "rect".expression()
            let instance = try evaluator.evaluate(expression: expr, to: CGArea.self)
            try expect(instance.size) == CGSize(width: 50, height: 50)
        }
        $0.it("throws if an instance is not present") {
            let expr = "none".expression()
            try expect(try context.evaluate(expression: expr)).toThrow()
        }
    }
    
    describe("instance expression") {
        $0.it("returns a number instance") {
            let number = CRBNumberInstance(0.5)
            let expr = CRBExpression.instance(number)
            let inst = try evaluator.evaluate(expression: expr, to: CRBNumberInstance.self)
            try expect(inst.value) == number.value
        }
        $0.it("returns any given instance") {
            class SomeInstance : CRBPlainInstance { }
            let some = SomeInstance()
            let expr = CRBExpression.instance(some)
            let inst = try evaluator.evaluate(expression: expr, to: SomeInstance.self)
            try expect(ObjectIdentifier(inst)) == ObjectIdentifier(some)
        }
    }
    
    describe("function expression") {
        $0.it("evaluates a correct function to its result") {
            let mult = CRBFunctionInstance(argumentNames: [crbname("a"), crbname("b")], { (context) -> CRBInstance in
                let a = try downcast(try context.instance(with: crbname("a")), to: CRBNumberInstance.self).value
                let b = try downcast(try context.instance(with: crbname("b")), to: CRBNumberInstance.self).value
                return CRBNumberInstance(a * b)
            })
            let expr = CRBExpression.call(.instance(mult),
                                          arguments: [2.5.expression(), 4.0.expression()])
            let result = try evaluator.evaluate(expression: expr, to: CRBNumberInstance.self)
            try expect(result.value) == 10.0
        }
    }
    
    describe("placement expression") {
        $0.it("evaluates to a placement guide") {
            let placeExpression = Jane.o("size").at("top").at("right").distance(10).from("rect".at("left")).expression()
            let guide = try evaluator.evaluate(expression: placeExpression, to: CRBPlacementGuide.self)
            try expect(guide.anchorKeyPath) == crbpath("top", "right")
            try expect(ObjectIdentifier(guide.objectToPlace)) == ObjectIdentifier(sizeObj)
            try expect(guide.pointToPlace) == rectObj.placed().anchor(at: crbpath("left"))!.placePoint(distance: 10.0)
        }
    }
    
}
