//
//  ViewController.swift
//  HelloWorld
//
//  Created by Innotact Software on 2018-11-23.
//  Copyright © 2018 Innotact Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint!
    
    var totalModelsInScene: Array<SCNNode> = []
    
    enum BodyType : Int {
        case objectModel = 2 //
    }
    
    private var newAngleY: Float = 0.0
    private var currentAngleY: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
      //  sceneView.debugOptions = [.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    
        screenCenter = view.center
        
        registerGestureRecognizers()
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let viewCenter = CGPoint(x: size.width/2, y: size.height/2)
        self.screenCenter = viewCenter
    }
    
    private func registerGestureRecognizers(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(moved))
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func panned(recognizer :UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else {return}
        
        let touch = recognizer.location(in: recognizerView)
        let translation = recognizer.translation(in: recognizerView)
        
        let hitTestResult = self.sceneView.hitTest(touch, options: [SCNHitTestOption.categoryBitMask: BodyType.objectModel.rawValue])
        guard let modelNodeHit = hitTestResult.first?.node else { return }
        if recognizer.state == .changed {
            self.newAngleY = Float(translation.x) * (Float) (Double.pi) / 180
            self.newAngleY += self.currentAngleY
            modelNodeHit.eulerAngles.y = self.newAngleY
        }else if recognizer.state == .ended {
            self.currentAngleY = self.newAngleY
        }
    }
    
    @objc func moved(recognizer :UILongPressGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        
        let touch = recognizer.location(in: recognizerView)
        
        let hitTestResult = self.sceneView.hitTest(touch, options: [SCNHitTestOption.categoryBitMask: BodyType.objectModel.rawValue])
        guard let modelNodeHit = hitTestResult.first?.node else { return }

        if recognizer.state == .changed {
            let hitTestPlane = self.sceneView.hitTest(touch, types: .existingPlane)
            if let planeHit = hitTestPlane.first{
                modelNodeHit.position = SCNVector3(planeHit.worldTransform.columns.3.x,modelNodeHit.position.y,planeHit.worldTransform.columns.3.z)
            }
        }
    }
    
    @objc func pinched(recognizer :UIPinchGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        
        let touch = recognizer.location(in: recognizerView)
        
        let hitTestResult = self.sceneView.hitTest(touch, options: [SCNHitTestOption.categoryBitMask: BodyType.objectModel.rawValue])
        guard let modelNodeHit = hitTestResult.first?.node else { return }
        
        if recognizer.state == .changed {
            let pinchScaleX = Float(recognizer.scale) * modelNodeHit.scale.x
            let pinchScaleY = Float(recognizer.scale) * modelNodeHit.scale.y
            let pinchScaleZ = Float(recognizer.scale) * modelNodeHit.scale.z
            modelNodeHit.scale = SCNVector3(x: pinchScaleX, y: pinchScaleY, z: pinchScaleZ)
            recognizer.scale = 1
        }
    }
 
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        print("tapped")
    }

    func updateFocusSquare(){
        guard let focusSquareLocal = self.focusSquare else {return}
        
        //following part is for hiding and showing focusSquare when object is placed
       /* guard let pointOfView = sceneView.pointOfView else {return}
        let firstVisibleModel = totalModelsInScene.first { (node) -> Bool in
            return sceneView.isNode(node, insideFrustumOf: pointOfView)
        }
        let modelsAreVisible = firstVisibleModel != nil
        if modelsAreVisible != focusSquareLocal.isHidden{
            focusSquareLocal.setHidden(to: modelsAreVisible)
        }
        */
        
        let hitTest = sceneView.hitTest(self.screenCenter, types: .existingPlaneUsingExtent) //Within plane bounds?
        if let hitTestResult = hitTest.first{
            let canAddNewModel = hitTestResult.anchor is ARPlaneAnchor
            focusSquareLocal.isClosed = canAddNewModel
        }else{
            focusSquareLocal.isClosed = false
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
