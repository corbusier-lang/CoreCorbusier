import XCTest
@testable import Jane
@testable import CoreCorbusier

class JaneTests: XCTestCase {
    
    func makeContext() -> (CRBContext, CGArea, CGArea) {
        let rect = CGArea(rect: .init(x: 0, y: 0, width: 100, height: 100))
        let area = CGArea(size: .init(width: 50, height: 50))
        let area2 = CGArea(size: .init(width: 100, height: 100))
        
        var context = CRBContext()
        context.currentScope.instances = [
            crbname("point"): CRBPointInstance.init(point: CRBPoint.init(x: 5, y: 10)),
            crbname("rect"): rect,
            crbname("area"): area,
            crbname("area2"): area2,
            crbname("print"): CRBExternalFunctionInstance.print(),
        ]
        return (context, area, area2)
    }
    
    func testExample() throws {
        
        let (context, area, area2) = makeContext()
        
        try jane(in: context) { j in
            j.place(o("area").at("left").at("top").distance(10).from("rect"["right"]["top"]))
            j.let_("bottom").equals("area"["bottom"])
            j.let_("guide").equals(o("area2").at("top").distance(50).from("bottom"))
            j.place("guide")
            j.let_("fifteen").equals("add".call(5.0, 10.0))
        }
        
        dump(area)
        dump(area2)
        
    }
    
    func testDecl() throws {
        
        var (context, _, _) = makeContext()
        
        try jane(in: &context, { (j) in
            j.define.f("add_twice").args("a", "b").build({ (c) in
                c.let_("added_first").equals("add".call("a", "b"))
                c.let_("added_twice").equals("add".call("added_first", "b"))
                c.retur("added_twice")
            })
            j.let_("added").equals("add_twice".call(5.0, 10.0))
            j.e("print".call("added"))
        })
        
    }
    
    func testDeclSubtract() throws {
        
        var context = CRBContext()
        try jane(in: &context, { (j) in
            
            j.define.f("subtract").args("a", "b").build({ (f) in
                f.let_("second_minus").equals("negate".call("b"))
                f.retur("add".call("a", "second_minus"))
            })
            j.retur("subtract".call(10.0, 5.0))
            
        })
        let num = context.returningValue as! CRBNumberInstance
        XCTAssertEqual(num.value, 5.0)
        
    }
    
    func testIf() throws {
        
        var (context, _, _) = makeContext()
        let equals = CRBExternalFunctionInstance { args in
            let left = args[0] as! CRBNumberInstance
            let right = args[1] as! CRBNumberInstance
            let areEqual = left.value == right.value
            return CRBBoolInstance(areEqual)
        }
        context.currentScope.instances[crbname("equals")] = equals
        
        try jane(in: &context, { (j) in
            j.if_("equals".call(5.0, 5.0)).do_({ (c) in
                c.retur(10.0)
            }).else_({ (c) in
                c.retur(10.0)
            })
        })
        let num = context.returningValue as! CRBNumberInstance
        XCTAssertEqual(num.value, 10.0)
        
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
