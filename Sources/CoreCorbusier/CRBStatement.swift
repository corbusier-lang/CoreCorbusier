//
//  CRBStatement.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public enum CRBStatement {
    
    case place(Placement)
    case expression(CRBExpression)
    
    public enum Placement {
        case expression(CRBPlaceExpression)
    }
    
}
