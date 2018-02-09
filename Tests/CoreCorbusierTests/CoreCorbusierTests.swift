import XCTest
import CoreCorbusier

class CoreCorbusierTests: XCTestCase {
    
    func testSpectre() {
        testExpressionEvaluator()
        testStatements()
        let testResult = globalContext.run(reporter: StandardReporter())
        XCTAssertTrue(testResult)
    }
    
    func testCGRect() {
        let cgrect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let rect = CGArea(rect: cgrect)
        let bottomAnchorName = CRBAnchorName(rawValue: "bottom")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: [bottomAnchorName]))
        let placed = try! rect.placed()
        let bottomAnchor = placed.anchor(with: bottomAnchorName)!
        let bottomPoint = bottomAnchor.point
        let bottomVector = bottomAnchor.normalizedVector
        print(bottomPoint, bottomVector)
        
        let topAnchorName = CRBAnchorName(rawValue: "top")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: [topAnchorName]))
        let topAnchor = placed.anchor(with: topAnchorName)!
        let topPoint = topAnchor.point
        let topVector = topAnchor.normalizedVector
        print(topPoint, topVector)
        
        let unexistingAnchor = CRBAnchorName(rawValue: "unreal")
        XCTAssertFalse(rect.isAnchorSupported(anchorName: [unexistingAnchor]))
        XCTAssertNil(placed.anchor(with: unexistingAnchor))
    }
    
    func testExecute() throws {
        let first = CGArea(rect: CGRect(x: 0, y: 0, width: 40, height: 40))
        let unplaced = CGArea(size: CGSize(width: 30, height: 30))
        var originalContext = CRBContext()
        originalContext.instances = [
            crbname("first") : first,
            crbname("unplaced") : unplaced,
            crbname("add") : CRBFunctionInstance.add(),
            crbname("print") : CRBExternalFunctionInstance.print()
        ]
        
        var context = originalContext
        
        let placeUnplaced: CRBStatement = {
            let firstObjectAnchor = CRBExpression.reference(crbname("first"), crbpath("bottom"))
            let unplacedObjectAnchor = CRBPlaceExpression.ObjectAnchor(objectName: crbname("unplaced"),
                                                                       anchorKeyPath: [crbname("top"), crbname("left")])
            let distanceExpression = CRBExpression.instance(CRBNumberInstance(10.0))
            let placeExpression = CRBPlaceExpression(toPlace: unplacedObjectAnchor,
                                                     distance: distanceExpression,
                                                     anchorPointToPlaceFrom: firstObjectAnchor)
            let placeUnplacedExpression = CRBExpression.placement(placeExpression)
            return .place(placeUnplacedExpression)
        }()
        try context.execute(statement: placeUnplaced)
        
        let assign: CRBStatement = {
            let instanceExpression = CRBExpression.reference(crbname("unplaced"), [])
            return CRBStatement.assign(crbname("assigned"), instanceExpression)
        }()
        try context.execute(statement: assign)
        
        let funcAndAssign: CRBStatement = {
            let function = CRBExpression.reference(crbname("add"), [])
            let arguments = [5.0, 15.0].map(CRBNumberInstance.init).map(CRBExpression.instance)
            let functionCallExpression = CRBExpression.call(function, arguments: arguments)
            let assign = CRBStatement.assign(crbname("fifteen"), functionCallExpression)
            return assign
        }()
        try context.execute(statement: funcAndAssign)
        
        let printStatement: CRBStatement = {
            let function = CRBExpression.reference(crbname("print"), [])
            let argument = CRBExpression.reference(crbname("assigned"), crbpath("top"))
            let functionCall = CRBExpression.call(function, arguments: [argument])
            return CRBStatement.unused(functionCall)
        }()
        try context.execute(statement: printStatement)
        
        let defineAddTwice: CRBStatement = {
            let addFunctionCall = CRBExpression.call(CRBExpression.reference(crbname("add"), []), arguments: [CRBExpression.reference(crbname("a"), []), CRBExpression.reference(crbname("b"), [])])
            let firstAddStatement = CRBStatement.assign(crbname("addedFirst"), addFunctionCall)
            let addSecondFunctionCall = CRBExpression.call(CRBExpression.reference(crbname("add"), []), arguments: [CRBExpression.reference(crbname("addedFirst"), []), CRBExpression.reference(crbname("b"), [])])
            let returnStatement = CRBStatement.return(addSecondFunctionCall)
            return CRBStatement.define(crbname("add_twice"), [crbname("a"), crbname("b")], [firstAddStatement, returnStatement])
        }()
        try context.execute(statement: defineAddTwice)
        
        let evalAddTwice: CRBStatement = {
            let a = CRBExpression.instance(CRBNumberInstance.init(5))
            let b = CRBExpression.instance(CRBNumberInstance.init(10))
            let functionExpr = CRBExpression.reference(crbname("add_twice"), [])
            let addTwiceExpr = CRBExpression.call(functionExpr, arguments: [a, b])
            let assign = CRBStatement.assign(crbname("added"), addTwiceExpr)
            return assign
        }()
        try context.execute(statement: evalAddTwice)
        
        let added = try context.instance(with: crbname("added")) as! CRBNumberInstance
        XCTAssertEqual(added.value, 25)
        
        let object = try context.object(with: crbname("assigned"))
        dump(object)
        
        let rct = try (unplaced.placed() as! Rect).rect
        XCTAssertEqual(rct, CGRect.init(x: 20, y: -40, width: 30, height: 30))
        
        dump(context)
        XCTAssertNotEqual(context, originalContext)
        XCTAssertEqual(context, context)
    }
    
}
