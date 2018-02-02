//
//  CRBObject.swift
//  CoreCorbusier
//
//  Created by Олег on 01.02.2018.
//

public protocol CRBObject : AnyObject {
    
    func isAnchorSupported(anchorName: CRBAnchorName) -> Bool
    func anchor(with name: CRBAnchorName) -> CRBAnchor?
    
}

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

