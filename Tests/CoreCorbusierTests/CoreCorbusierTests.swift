import XCTest
import CoreCorbusier

func ~=<T : Equatable>(array: [T], value: [T]) -> Bool {
    return array == value
}

struct CGSizeSide : CRBAnchorEnvironment {
    
    let a: CRBPoint
    let b: CRBPoint
    let vector: CRBNormalizedVector
    
    var medium: CRBPoint {
        return CRBPoint.between(a, b, multiplier: 0.5)
    }
    
    var names: (CRBAnchorName, CRBAnchorName, CRBAnchorName)
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        if name == names.0 {
            return CRBAnchor(point: a,
                             normalizedVector: vector)
        } else if name == names.1 {
            return CRBAnchor(point: medium,
                             normalizedVector: vector)
        } else if name == names.2 {
            return CRBAnchor(point: b,
                             normalizedVector: vector)
        }
        return nil
    }
    
}

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
    
    func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        let cgrect: CGRect
        let path = keyPath.map({ $0.rawValue })
        switch path {
        case ["top", "left"], ["left", "top"]:
            cgrect = CGRect(origin: CGPoint.init(x: point.x, y: point.y + size.height), size: size)
        case ["top", "center"], ["top"]:
            cgrect = CGRect(origin: CGPoint.init(x: point.x + size.width / 2, y: point.y + size.height), size: size)
        case ["top", "right"], ["right", "top"]:
            cgrect = CGRect(origin: CGPoint.init(x: point.x + size.width, y: point.y + size.height), size: size)
        default:
            cgrect = .zero
        }
        self.state = .placed(Rect(rect: cgrect))
    }
    
    func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        return Rect(rect: .zero).anchor(at: anchorName) != nil
    }
    
}

class Rect : CRBAnchorEnvironment {
    
    fileprivate let rect: CGRect
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        switch name.rawValue {
        case "top":
            let side = CGSizeSide(a: CRBPoint.init(x: rect.minX, y: rect.maxY),
                                  b: CRBPoint.init(x: rect.maxX, y: rect.maxY),
                                  vector: CRBVector.init(dx: 0, dy: +1).alreadyNormalized(),
                                  names: (crbname("left"), crbname("center"), crbname("right")))
            return CRBAnchor(point: side.medium, normalizedVector: side.vector, child: side)
        case "bottom":
            let side = CGSizeSide(a: .init(x: rect.minX, y: rect.minY),
                                  b: .init(x: rect.maxX, y: rect.minY),
                                  vector: CRBVector.init(dx: 0, dy: -1).alreadyNormalized(),
                                  names: (crbname("left"), crbname("center"), crbname("right")))
            return CRBAnchor(point: side.medium, normalizedVector: side.vector, child: side)
        case "left":
            let side = CGSizeSide(a: .init(x: rect.minX, y: rect.minY),
                                  b: .init(x: rect.minX, y: rect.maxY),
                                  vector: CRBVector.init(dx: -1, dy: 0).alreadyNormalized(),
                                  names: (crbname("bottom"), crbname("center"), crbname("top")))
            return CRBAnchor(point: side.medium, normalizedVector: side.vector, child: side)
        case "right":
            let side = CGSizeSide(a: .init(x: rect.maxX, y: rect.minY),
                                  b: .init(x: rect.maxX, y: rect.maxY),
                                  vector: CRBVector.init(dx: +1, dy: 0).alreadyNormalized(),
                                  names: (crbname("bottom"), crbname("center"), crbname("top")))
            return CRBAnchor(point: side.medium, normalizedVector: side.vector, child: side)
        default:
            return nil
        }
    }
    
}

class CoreCorbusierTests: XCTestCase {
    
    func testCGRect() {
        let cgrect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let rect = RectObject(rect: cgrect)
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
                                                                    anchorKeyPath: [crbname("bottom")])
            let unplacedObjectAnchor = CRBPlaceExpression.ObjectAnchor(objectName: crbname("unplaced"),
                                                                       anchorKeyPath: [crbname("top"), crbname("left")])
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
