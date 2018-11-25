//
//  ViewController+ARSCNViewDelegate.swift
//  HelloWorld
//
//  Created by Innotact Software on 2018-11-24.
//  Copyright © 2018 Innotact Software. All rights reserved.
//

import SceneKit
import ARKit

extension ViewController: ARSCNViewDelegate{
    
    // Create a plane when new anchor is found in the Scene Views session
    // also create a focus square
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{return}
        let planeNode = createPlane(planeAnchor)
        node.addChildNode(planeNode)
        
        guard self.focusSquare == nil else{return}
        let focusSquareLocal = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquareLocal)
        self.focusSquare = focusSquareLocal
        
    }
    
    // Update plane in order for it to dynamically change
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let updatedPlaneNode = createPlane(planeAnchor)
        node.addChildNode(updatedPlaneNode)
    }
    
    // Make sure the node is removed when plane is removed
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else{return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    // Update focus square position to screen center with hitTest. Call updateFocusSquare() to make sure position is within bounds of a plane
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let focusSquareLocal = self.focusSquare else {return}
        let hitTestNoBounds = sceneView.hitTest(screenCenter, types: .existingPlane)
        let hitTestPlaneBounds = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        
        let hitTestResultNoBounds = hitTestNoBounds.first
        let hitTestResultPlaneBounds = hitTestPlaneBounds.first
        
        let worldTransform : simd_float4x4?
        
        if hitTestResultPlaneBounds?.worldTransform != nil{     // If within a plane
            worldTransform = hitTestResultPlaneBounds!.worldTransform //use hitTest of that plane
        } else if hitTestResultNoBounds?.worldTransform != nil {
            worldTransform = hitTestResultNoBounds!.worldTransform
        }else{
            return
        }
        let position = worldTransform!.columns.3
        focusSquareLocal.position = SCNVector3(position.x, position.y+0.02, position.z)
        
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
        
    }
    
    // Plane creation and configuration
    func createPlane(_ planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let grid = UIImage(named: "grid.png")
        plane.firstMaterial?.diffuse.contents = grid
        plane.firstMaterial?.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        planeNode.eulerAngles.x = GLKMathDegreesToRadians(-90)
        
        return planeNode
    }
    
}

