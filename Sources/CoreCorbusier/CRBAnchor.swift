//
//  CRBAnchor.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public struct CRBAnchorName : RawRepresentable, Hashable {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}
