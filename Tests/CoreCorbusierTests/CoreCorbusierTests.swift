import XCTest
@testable import CoreCorbusier

class Rect : CRBObject {
    
    private let rect: CGRect
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    private enum Anchors : String {
        case top
        case bottom
    }
    
    func isAnchorSupported(anchorName anchor: CRBAnchorName) -> Bool {
        let anch = Anchors(rawValue: anchor.rawValue)
        return !(anch == nil)
    }
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        guard let anch = Anchors(rawValue: name.rawValue) else {
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
        let rect = Rect(rect: cgrect)
        let bottomAnchorName = CRBAnchorName(rawValue: "bottom")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: bottomAnchorName))
        let bottomAnchor = rect.anchor(with: bottomAnchorName)!
        let bottomPoint = bottomAnchor.point
        let bottomVector = bottomAnchor.normalizedVector
        print(bottomPoint, bottomVector)
        
        let topAnchorName = CRBAnchorName(rawValue: "top")
        XCTAssertTrue(rect.isAnchorSupported(anchorName: topAnchorName))
        let topAnchor = rect.anchor(with: topAnchorName)!
        let topPoint = topAnchor.point
        let topVector = topAnchor.normalizedVector
        print(topPoint, topVector)
        
        let unexistingAnchor = CRBAnchorName(rawValue: "unreal")
        XCTAssertFalse(rect.isAnchorSupported(anchorName: unexistingAnchor))
        XCTAssertNil(rect.anchor(with: unexistingAnchor))
    }

}
