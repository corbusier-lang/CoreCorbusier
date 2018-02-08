//
//  CRBStatement.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public enum CRBStatement {
    
    case ordered([CRBStatement])
    case assign(CRBInstanceName, CRBExpression)
    case place(CRBExpression)
    case unused(CRBExpression)
    case define(CRBFunctionName, [CRBArgumentName], [CRBStatement])
    case `return`(CRBExpression)
    
    public enum Placement {
        case expression(CRBPlaceExpression)
    }
    
}
