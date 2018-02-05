//
//  CRBObject.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public protocol CRBObject : CRBInstance {
    
    func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool

    var state: CRBObjectState { get }
    
    func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath)
    
}

extension CRBObject {
    
    public func value(for propertyName: CRBPropertyName) -> CRBInstance? {
        guard let placed = try? self.placed() else {
            return nil
        }
        guard let anchor = placed.anchor(with: converted(propertyName)) else {
            return nil
        }
        return CRBAnchorInstance(anchor: anchor)
    }
    
    public func placed() throws -> CRBAnchorEnvironment {
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
    
    case placed(CRBAnchorEnvironment)
    case unplaced
    
    enum Error : Swift.Error {
        case isUnplaced(CRBObject)
        case isAlreadyPlaced(CRBObject)
    }
    
}

public protocol CRBAnchorEnvironment {
    
    func anchor(with name: CRBAnchorName) -> CRBAnchor?
    
}

extension CRBAnchorEnvironment {
    
    public func anchor(at keyPath: CRBAnchorKeyPath) -> CRBAnchor? {
        var currentEnv: CRBAnchorEnvironment = self
        var keyPath = keyPath
        let lastName = keyPath.popLast()!
        for name in keyPath {
            if let deeper = currentEnv.anchor(with: name) {
                currentEnv = deeper
            } else {
                return nil
            }
        }
        return currentEnv.anchor(with: lastName)
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

