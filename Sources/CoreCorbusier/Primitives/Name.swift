//
//  Name.swift
//  CoreCorbusier
//
//  Created by Олег on 04.02.2018.
//

public struct Name<T> : RawRepresentable, Hashable {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
}

public func crbname<T, V>(_ converted: Name<V>) -> Name<T> {
    return Name<T>(rawValue: converted.rawValue)
}

public func crbname<T>(_ rawName: String) -> Name<T> {
    return Name<T>(rawValue: rawName)
}
