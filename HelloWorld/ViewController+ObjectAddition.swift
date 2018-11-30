//
//  ViewController+ObjectAddition.swift
//  HelloWorld
//
//  Created by Innotact Software on 2018-11-25.
//  Copyright © 2018 Innotact Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController {
    
    fileprivate func getModel(named name: String) -> SCNNode?{
        let scene = SCNScene(named: "art.scnassets/\(name)/\(name).scn")
        guard let model = scene?.rootNode.childNode(withName: "SketchUp", recursively: false)
            else{ return nil }
        
        model.name = name
        
        let min = model.boundingBox.min
        let max = model.boundingBox.max
        
        model.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x) / 2,
            min.y + (max.y - min.y) / 2,
            min.z + (max.z - min.z) / 2)
        
        var scale: CGFloat
        
        switch name {
        case "iPhoneX":         scale = 0.025
        case "iPhone6s":        scale = 0.025
        case "iPhone7":         scale = 0.0001
        case "iPhone8":         scale = 0.000008
        case "iPhone8Plus":     scale = 0.000008
        case "iPad4":           scale = 0.00054
        case "MacBookPro13":    scale = 0.0022
        case "iMacPro":         scale = 0.0245
        case "AppleWatch":      scale = 0.0000038
        default:                scale = 1
        }
        
        model.scale = SCNVector3(scale, scale, scale)
        
        return model
    }
    
    @IBAction func addObjectButtonTapped(_ sender: Any) {
        
        guard self.focusSquare != nil else {return}
        
        let modelName = "iPhoneX"
        guard let model = getModel(named: modelName)
            else {
                print("Unable to load model \(modelName)")
                return
        }
        
        let hitTest = sceneView.hitTest(self.screenCenter, types: .existingPlaneUsingExtent)
        guard let position = hitTest.first?.worldTransform.columns.3 else {return}
        model.position = SCNVector3(position.x, position.y, position.z)
        model.categoryBitMask = BodyType.objectModel.rawValue
        sceneView.scene.rootNode.addChildNode(model)
        totalModelsInScene.append(model)
    //  print(totalModelsInScene.count)
        
    }
    
}
