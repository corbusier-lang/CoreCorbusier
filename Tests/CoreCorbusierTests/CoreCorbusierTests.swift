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
    
    func isAnchorSupported(_ anchor: CRBAnchorName) -> Bool {
        let anch = Anchors(rawValue: anchor.rawValue)
        return !(anch == nil)
    }
    
    func point(of anchor: CRBAnchorName) -> CRBPoint {
        let anch = Anchors(rawValue: anchor.rawValue)!
        switch anch {
        case .bottom:
            return CRBPoint(x: rect.minX + rect.width / 2, y: rect.minY)
        case .top:
            return CRBPoint(x: rect.minX + rect.width, y: rect.maxY)
        }
    }
    
    func normalizedVector(for anchor: CRBAnchorName) -> CRBNormalizedVector {
        let anch = Anchors(rawValue: anchor.rawValue)!
        switch anch {
        case .bottom:
            return CRBVector(dx: 0, dy: -1).alreadyNormalized()
        case .top:
            return CRBVector(dx: 0, dy: +1).alreadyNormalized()
        }
    }
    
}

class CoreCorbusierTests: XCTestCase {
    
    func testCGRect() {
        let cgrect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let rect = Rect(rect: cgrect)
        let bottomAnchor = CRBAnchorName(rawValue: "bottom")
        XCTAssertTrue(rect.isAnchorSupported(bottomAnchor))
        let bottomPoint = rect.point(of: bottomAnchor)
        let bottomVector = rect.normalizedVector(for: bottomAnchor)
        print(bottomPoint, bottomVector)
        
        let topAnchor = CRBAnchorName(rawValue: "top")
        XCTAssertTrue(rect.isAnchorSupported(topAnchor))
        let topPoint = rect.point(of: topAnchor)
        let topVector = rect.normalizedVector(for: topAnchor)
        print(topPoint, topVector)
        
        let unexistingAnchor = CRBAnchorName(rawValue: "unreal")
        XCTAssertFalse(rect.isAnchorSupported(unexistingAnchor))
    }

}
