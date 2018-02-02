//
//  CRBSize.swift
//  CoreCorbusier
//
//  Created by Олег on 02.02.2018.
//

public struct CRBSize {
    
    public var width: CRBFloat
    public var height: CRBFloat
    
    public init(width: CRBFloat, height: CRBFloat) {
        self.width = width
        self.height = height
    }
    
    public static var zero: CRBSize {
        return CRBSize(width: 0, height: 0)
    }
    
}
