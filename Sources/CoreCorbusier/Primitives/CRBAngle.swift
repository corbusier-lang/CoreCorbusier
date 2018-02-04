//
//  CRBAngle.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

// inspired by https://github.com/erica/SwiftGeometry/blob/master/Sources/CGAngle.swift by Erica Sadun

// Core Graphics-facing Angles
public struct CRBAngle {
    
    /// The pi constant
    public static let (pi, π) = (CRBFloat(Double.pi), CRBFloat(Double.pi))
    
    /// The tau constant
    public static let (tau, τ)  = (2 * pi, 2 * pi)
    
    /// Init
    public init() { _radians = 0 }
    
    /// Initialize with radians
    public init(radians: CRBFloat) { _radians = radians }
    
    /// Initialize with degrees
    public init(degrees: CRBFloat) { _radians = degrees * CRBAngle.pi / 180.0 }
    
    /// Initialize with count of π's
    public init(piCount: CRBFloat) { _radians = piCount * CRBAngle.pi }
    
    /// Express angle in degrees
    public var degrees: CRBFloat { return _radians * 180.0 / CRBAngle.pi }
    
    /// Express angles as a count of pi
    public var piCount: CRBFloat { return _radians / CRBAngle.pi }
    
    /// Express angle in (native) radians
    public var radians: CRBFloat {
        get { return _radians }
        set { _radians = radians }
    }
    /// Internal radian store
    private var _radians: CRBFloat
}

extension CRBAngle : Hashable {
    
    public var hashValue: Int {
        return _radians.hashValue
    }
    
    public static func ==(lhs: CRBAngle, rhs: CRBAngle) -> Bool {
        return lhs._radians == rhs._radians
    }
    
}

extension CRBAngle : CustomStringConvertible {
    
    /// String convertible support
    public var description: String {
        return "\(degrees)°, \(piCount)π, \(radians) rads"
    }
    
}
