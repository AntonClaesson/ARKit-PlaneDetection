//
//  FocusSquare.swift
//  HelloWorld
//
//  Created by Innotact Software on 2018-11-24.
//  Copyright © 2018 Innotact Software. All rights reserved.
//

import SceneKit

class FocusSquare: SCNNode{
    
    var isClosed: Bool = true {
        didSet{
            geometry?.firstMaterial?.diffuse.contents =
                self.isClosed ? UIImage(named: "close") : UIImage(named: "open")
        }
    }
    
    override init() {
        super.init()
        
        let plane = SCNPlane(width: 0.1, height: 0.1)
        let texture = UIImage(named: "FocusSquare/close")
        plane.firstMaterial?.diffuse.contents = texture
        plane.firstMaterial?.isDoubleSided = true
        self.geometry = plane
        self.eulerAngles.x = GLKMathDegreesToRadians(-90)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

