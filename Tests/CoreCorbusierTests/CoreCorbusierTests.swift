import XCTest
import CoreCorbusier

class RectObject : CRBObject {
    
    fileprivate enum Anchors : String {
        case top
        case bottom
    }
    
    fileprivate enum PlaceAnchor : String {
        case topLeft
    }
    
    var state: CRBObjectState
    fileprivate let size: CGSize
    
    init(size: CGSize) {
        self.size = size
        self.state = .unplaced
    }
    
    init(rect: CGRect) {
        self.size = rect.size
        let rect = Rect(rect: rect)
        self.state = .placed(rect)
    }
    
    func place(at point: CRBPoint, fromAnchorWith name: CRBAnchorName) {
        let anchor = PlaceAnchor(rawValue: name.rawValue)!
        let cgrect: CGRect
        switch anchor {
        case .topLeft:
            cgrect = CGRect(origin: CGPoint.init(x: point.x, y: point.y),
                            size: self.size)
        }
        let rect = Rect(rect: cgrect)
        self.state = .placed(rect)
    }
    
    func isAnchorSupported(anchorName: CRBAnchorName) -> Bool {
        if isUnplaced {
            return PlaceAnchor(rawValue: anchorName.rawValue) != nil
        } else {
            return Anchors(rawValue: anchorName.rawValue) != nil
        }
    }
    
}

class Rect : CRBPlacedObjectTrait {
    
    fileprivate let rect: CGRect
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        guard let anch = RectObject.Anchors(rawValue: name.rawValue) else {
            return nil
        }
        switch anch {
        case .top:
            let point = CRBPoint(x: rect.minX + rect.width, y: rect.maxY)
            let vector = CRBVector(dx: 0, dy: +1).alreadyNormalized()
            return CRBAnchor(point: point, normalizedVector: vector)
        case .bottom:
            let point = CRBPoint(x: rect.minX + rect.width / 2, y: rect.minY)
            let vector = CRBVector(dx: 0, dy: -1).alreadyNormalized()
            return CRBAnchor(point: point, normalizedVector: vector)
        }
    }
    
}

class CoreCorbusierTests: XCTestCase {
    
    func testCGRect() {
        let cgrect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let rect = RectObject(rect: cgrect)
        let bottomAnchorName = CRBAnchorName(rawValue: "bottom")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: bottomAnchorName))
        let placed = try! rect.placed()
        let bottomAnchor = placed.anchor(with: bottomAnchorName)!
        let bottomPoint = bottomAnchor.point
        let bottomVector = bottomAnchor.normalizedVector
        print(bottomPoint, bottomVector)
        
        let topAnchorName = CRBAnchorName(rawValue: "top")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: topAnchorName))
        let topAnchor = placed.anchor(with: topAnchorName)!
        let topPoint = topAnchor.point
        let topVector = topAnchor.normalizedVector
        print(topPoint, topVector)
        
        let unexistingAnchor = CRBAnchorName(rawValue: "unreal")
        XCTAssertFalse(rect.isAnchorSupported(anchorName: unexistingAnchor))
        XCTAssertNil(placed.anchor(with: unexistingAnchor))
    }
    
    func testExecute() throws {
        let first = RectObject(rect: CGRect(x: 0, y: 0, width: 40, height: 40))
        let unplaced = RectObject(size: CGSize(width: 30, height: 30))
        var context = CRBContext()
        context.instances = [
            crbname("first") : first,
            crbname("unplaced") : unplaced,
        ]
        
        var executor = CRBExecution(context: context)
        
        let placeUnplaced: CRBStatement = {
            let firstObjectAnchor = CRBPlaceExpression.ObjectAnchor(objectName: crbname("first"),
                                                                    anchorName: crbname("bottom"))
            let unplacedObjectAnchor = CRBPlaceExpression.ObjectAnchor(objectName: crbname("unplaced"),
                                                                       anchorName: crbname("topLeft"))
            let placeExpression = CRBPlaceExpression(toPlace: unplacedObjectAnchor, distance: 10, anchorPointToPlaceFrom: .ofObject(firstObjectAnchor))
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
        
        print(try (unplaced.placed() as! Rect).rect)
    }

}
