//
//  StatementExecutorSpec.swift
//  CoreCorbusierTests
//
//  Created by Олег on 09.02.2018.
//

import Jane
import CoreCorbusier

func testStatements() {
    
    let rectObj = CGArea(rect: .init(x: 10, y: 10, width: 50, height: 50))
    let sizeObj = CGArea(size: .init(width: 40, height: 40))
    let originalContext = CRBContext(instances: [
        crbname("rect"): rectObj,
        crbname("size"): sizeObj
    ])
    let executor = CRBStatementExecutor()
    
    describe("place statement") {
        $0.it("asks object to place itself on execution") {
            let stub = Stub()
            let (anchorName, point) = (crbpath("supported") as CRBAnchorKeyPath, CRBPoint.zero)
            let guide = CRBPlacementGuide(objectToPlace: stub, anchorName: anchorName, pointToPlace: point)
            let guideExpr = CRBExpression.instance(guide)
            let stat = CRBStatement.place(guideExpr)
            var context = originalContext
            try executor.execute(statement: stat, in: &context)
            try expect(stub.placeCall!.0) == point
            try expect(stub.placeCall!.1) == anchorName
        }
        $0.it("throws if an anchor is unsupported") {
            let stub = Stub()
            stub.unsupportedAnchors = [crbpath("unsupported")]
            let guide = CRBPlacementGuide(objectToPlace: stub, anchorName: crbpath("unsupported"), pointToPlace: .zero)
            let guideExpr = CRBExpression.instance(guide)
            let stat = CRBStatement.place(guideExpr)
            var context = originalContext
            try expect(try executor.execute(statement: stat, in: &context)).toThrow()
        }
        $0.it("doesnt modify the context") {
            let stub = Stub()
            let (anchorName, point) = (crbpath("supported") as CRBAnchorKeyPath, CRBPoint.zero)
            let guide = CRBPlacementGuide(objectToPlace: stub, anchorName: anchorName, pointToPlace: point)
            let guideExpr = CRBExpression.instance(guide)
            let stat = CRBStatement.place(guideExpr)
            var context = originalContext
            try executor.execute(statement: stat, in: &context)
            try expect(context) == originalContext
        }
    }
    
    describe("assign statement") {
        $0.it("sets an instance to a given name in a context") {
            let number = CRBNumberInstance(5.0)
            var context = originalContext
            var expectedContext = originalContext
            expectedContext.instances[crbname("number")] = number
            let assignStatement = CRBStatement.assign(crbname("number"), .instance(number))
            try executor.execute(statement: assignStatement, in: &context)
            try expect(context) == expectedContext
        }
        $0.it("throws if an expression is unsolvable") {
            let unrealExpression = "notexisting".expression()
            let assign = CRBStatement.assign(crbname("new"), unrealExpression)
            var context = originalContext
            try expect(try executor.execute(statement: assign, in: &context)).toThrow()
        }
    }
    
    describe("ordered statement") {
        $0.it("performs every statement of a group") {
            let number1 = CRBNumberInstance(5.0)
            let number2 = CRBNumberInstance(10.0)
            let assignStatement1 = CRBStatement.assign(crbname("one"), .instance(number1))
            let assignStatement2 = CRBStatement.assign(crbname("two"), .instance(number2))
            let composed = CRBStatement.ordered([assignStatement1, assignStatement2])
            var context = originalContext
            var expectedContext = originalContext
            expectedContext.instances[crbname("one")] = number1
            expectedContext.instances[crbname("two")] = number2
            try executor.execute(statement: composed, in: &context)
            try expect(context) == expectedContext
        }
    }
    
    describe("unused expression statement") {
        $0.it("evaluates an expression") {
            var wasExecuted = false
            let function = CRBExternalFunctionInstance { _ in
                wasExecuted = true
                return CRBNumberInstance(5.0)
            }
            let functionCall = CRBExpression.call(.instance(function), arguments: [])
            var context = originalContext
            let unused = CRBStatement.unused(functionCall)
            try executor.execute(statement: unused, in: &context)
            try expect(wasExecuted) == true
            try expect(context) == originalContext
        }
    }
    
    describe("define statement") {
        $0.it("adds a function to instances") {
            var context = originalContext
            let jane = JaneContext()
            jane.define.f("newfunc").args().build({ (c) in
                c.retur(void)
            })
            let defStatement = jane.statements[0]
            guard case .define = defStatement else {
                throw "Not a define statement"
            }
            try executor.execute(statement: defStatement, in: &context)
            _ = try context.instance(with: crbname("newfunc"))
            context.instances[crbname("newfunc")] = nil
            try expect(context) == originalContext
        }
    }
    
}

extension String : Error { }

class Stub : CRBObject {
    var placeCall: (CRBPoint, CRBAnchorKeyPath)? = nil
    var unsupportedAnchors: [CRBAnchorKeyPath] = []
    func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        return !unsupportedAnchors.contains(where: { $0 == anchorName })
    }
    func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        placeCall = (point, keyPath)
    }
    var state: CRBObjectState = .unplaced
}

struct MockTrait : CRBAnchorEnvironment {
    var p: CRBPoint
    func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        switch name {
        case "zero":
            return CRBAnchor(point: p, normalizedVector: CRBVector.init(dx: 1, dy: 0).alreadyNormalized())
        default:
            return nil
        }
    }
}
class Mock : CRBObject {
    func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        switch anchorName[0] {
        case "supported":
            return true
        default:
            return false
        }
    }
    var state: CRBObjectState = .unplaced
    func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        switch keyPath[0] {
        case "supported":
            self.state = .placed(MockTrait(p: point))
        default:
            fatalError()
        }
    }
}

