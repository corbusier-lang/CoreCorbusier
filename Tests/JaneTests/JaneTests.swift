import XCTest
@testable import Jane
@testable import CoreCorbusier

class JaneTests: XCTestCase {
    
    func makeContext() -> (CRBContext, CGArea, CGArea) {
        let rect = CGArea(rect: .init(x: 0, y: 0, width: 100, height: 100))
        let area = CGArea(size: .init(width: 50, height: 50))
        let area2 = CGArea(size: .init(width: 100, height: 100))
        
        var context = CRBContext()
        context.instances = [
            crbname("point"): CRBPointInstance.init(point: CRBPoint.init(x: 5, y: 10)),
            crbname("rect"): rect,
            crbname("area"): area,
            crbname("area2"): area2,
            crbname("add"): CRBFunctionInstance.add(),
            crbname("print"): CRBExternalFunctionInstance.print(),
        ]
        return (context, area, area2)
    }
    
    func testExample() throws {
        
        let (context, area, area2) = makeContext()
        
        try jane(in: context) { j in
            j.place(o("area").at("left").at("top").distance(10).from("rect".at("right").at("top")))
            j.lett("bottom").equals("area".at("bottom"))
            j.lett("guide").equals(o("area2").at("top").distance(50).from("bottom"))
            j.place("guide")
            j.lett("fifteen").equals("add".call(5.0, 10.0))
        }
        
        dump(area)
        dump(area2)
        
    }
    
    func testDecl() throws {
        
        var (context, _, _) = makeContext()
        
        try jane(in: &context, { (j) in
            j.define.f("add_twice").args("a", "b").build({ (c) in
                c.lett("added_first").equals("add".call("a", "b"))
                c.lett("added_twice").equals("add".call("added_first", "b"))
                c.retur("added_twice")
            })
            j.lett("added").equals("add_twice".call(5.0, 10.0))
            j.e("print".call("added"))
        })
        
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
