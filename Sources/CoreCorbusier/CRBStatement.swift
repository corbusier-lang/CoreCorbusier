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
    
    public enum Placement {
        case expression(CRBPlaceExpression)
    }
    
}
