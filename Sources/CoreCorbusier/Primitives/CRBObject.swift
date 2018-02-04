//
//  CRBObject.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public protocol CRBObject : CRBInstance {
    
    func isAnchorSupported(anchorName: CRBAnchorName) -> Bool

    var state: CRBObjectState { get }
    
    func place(at point: CRBPoint, fromAnchorWith name: CRBAnchorName)
    
}

extension CRBObject {
    
    public func placed() throws -> CRBPlacedObjectTrait {
        if case .placed(let pl) = state {
            return pl
        }
        throw CRBObjectState.Error.isUnplaced(self)
    }
    
    public var isUnplaced: Bool {
        if case .unplaced = state {
            return true
        }
        return false
    }
    
    public var isPlaced: Bool {
        return !isUnplaced
    }
    
}

public enum CRBObjectState {
    
    case placed(CRBPlacedObjectTrait)
    case unplaced
    
    enum Error : Swift.Error {
        case isUnplaced(CRBObject)
        case isAlreadyPlaced(CRBObject)
    }
    
}

public protocol CRBPlacedObjectTrait {
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor?
    
}

extension CRBAnchor {
    
    public func placePoint(distance: CRBFloat) -> CRBPoint {
        let distancedVector = self.normalizedVector.asVector().multiplied(byScalar: distance)
        return self.point.shifted(with: distancedVector)
    }
    
}

public typealias CRBObjectName = Name<CRBObject>

//public class CRBObject {
//
//    public static func == (lhs: CRBObject, rhs: CRBObject) -> Bool {
//        return lhs === rhs
//    }
//
//    public let supportedAnchors: [CRBAnchor.Name]
//
//    private let pointOfAnchor: (CRBAnchor.Name) -> CRBPoint
//    private let normalizedVectorForAnchor: (CRBAnchor.Name) -> CRBVector
//
//    public init(anchors: [CRBAnchor.Name : CRBAnchor]) {
//        self.anchors = anchors
//    }
//
//    public
//
//}

