//
//  Place.swift
//  Jane
//
//  Created by Олег on 05.02.2018.
//

import CoreCorbusier
import Foundation

extension JaneContext {
    
    public func place(_ o: JaneExpression) {
        let statement = CRBStatement.place(o.expression())
        self.add(statement)
    }
    
}

public func o(_ name: String) -> JaneObjectToPlace {
    return JaneObjectToPlace(name: crbname(name))
}

public final class JaneObjectToPlace {
    
    let name: CRBObjectName
    
    init(name: CRBObjectName) {
        self.name = name
    }
    
    public func at(_ anchorName: String) -> JaneAnchorToPlace {
        return JaneAnchorToPlace(name: self.name, anchorKeyPath: crbpath(anchorName))
    }
    
}

public final class JaneAnchorToPlace {
    
    let name: CRBObjectName
    var anchorKeyPath: CRBAnchorKeyPath
    
    init(name: CRBObjectName, anchorKeyPath: CRBAnchorKeyPath) {
        self.name = name
        self.anchorKeyPath = anchorKeyPath
    }
    
    public func at(_ anchorName: String) -> JaneAnchorToPlace {
        var newKeyPath = anchorKeyPath
        newKeyPath.append(crbname(anchorName))
        return JaneAnchorToPlace(name: self.name, anchorKeyPath: newKeyPath)
    }
    
    public func distance(_ distance: Double) -> JaneDistancedAnchorToPlace {
        return JaneDistancedAnchorToPlace(anchor: self, distance: CRBFloat(distance))
    }
    
}

public final class JaneDistancedAnchorToPlace {
    
    let anchor: JaneAnchorToPlace
    let distance: CRBFloat
    
    init(anchor: JaneAnchorToPlace, distance: CRBFloat) {
        self.anchor = anchor
        self.distance = distance
    }
    
    public func from(_ i: JaneExpression) -> JanePlacement {
        return JanePlacement(anchor: self, expr: i)
    }
    
}

public final class JanePlacement : JaneExpression {
    
    let anchor: JaneDistancedAnchorToPlace
    let expr: JaneExpression
    
    init(anchor: JaneDistancedAnchorToPlace, expr: JaneExpression) {
        self.anchor = anchor
        self.expr = expr
    }
    
    public func expression() -> CRBExpression {
        let objAnch = CRBPlaceExpression.ObjectAnchor.init(objectName: anchor.anchor.name, anchorKeyPath: anchor.anchor.anchorKeyPath)
        let distance = CRBExpression.instance(CRBNumberInstance(anchor.distance))
        let placement = CRBPlaceExpression(toPlace: objAnch,
                                           distance: distance,
                                           anchorPointToPlaceFrom: expr.expression())
        return .placement(placement)
    }
    
}
