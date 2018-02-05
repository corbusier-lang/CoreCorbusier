import XCTest
import CoreCorbusier

class CoreCorbusierTests: XCTestCase {
    
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
        var context = CRBContext()
        context.instances = [
            crbname("first") : first,
            crbname("unplaced") : unplaced,
        ]
        
        var executor = CRBExecution(context: context)
        
        let placeUnplaced: CRBStatement = {
            let firstObjectAnchor = CRBExpression.subinstance(crbname("first"), crbpath("bottom"))
            let unplacedObjectAnchor = CRBPlaceExpression.ObjectAnchor(objectName: crbname("unplaced"),
                                                                       anchorKeyPath: [crbname("top"), crbname("left")])
            let placeExpression = CRBPlaceExpression(toPlace: unplacedObjectAnchor, distance: 10, anchorPointToPlaceFrom: firstObjectAnchor)
            let placeUnplacedExpression = CRBExpression.placement(placeExpression)
            return .place(placeUnplacedExpression)
        }()
        try executor.execute(statement: placeUnplaced)
        
        let assign: CRBStatement = {
            let instanceExpression = CRBExpression.instance(crbname("unplaced"))
            return CRBStatement.assign(crbname("assigned"), instanceExpression)
        }()
        try executor.execute(statement: assign)
        
        let object = try executor.context.object(with: crbname("assigned"))
        dump(object)
        
        let rct = try (unplaced.placed() as! Rect).rect
        XCTAssertEqual(rct, CGRect.init(x: 20, y: -40, width: 30, height: 30))
    }
    
}
