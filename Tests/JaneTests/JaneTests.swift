import XCTest
@testable import Jane
@testable import CoreCorbusier

class JaneTests: XCTestCase {
    
    func testExample() throws {
        
        let rect = CGArea(rect: .init(x: 0, y: 0, width: 100, height: 100))
        let area = CGArea(size: .init(width: 50, height: 50))
        let area2 = CGArea(size: .init(width: 100, height: 100))
        
        var context = CRBContext()
        context.instances = [
            crbname("point"): CRBPointInstance.init(point: CRBPoint.init(x: 5, y: 10)),
            crbname("rect"): rect,
            crbname("area"): area,
            crbname("area2"): area2,
            crbname("add"): CRBFunctionInstance.add()
        ]
        
        try jane(in: context) { j in
            j.place(o("area").at("left").at("top").distance(10).from(i("rect").at("right").at("top")))
            j.jlet("bottom").equals(i("area").at("bottom"))
            j.jlet("guide").equals(o("area2").at("top").distance(50).from(i("bottom")))
            j.place(i("guide"))
            j.jlet("fifteen").equals(i("add").call(i(5.0), i(10.0)))
        }
        
        dump(area)
        dump(area2)
        
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
