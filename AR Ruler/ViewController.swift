//
//  ViewController.swift
//  AR Ruler
//
//  Created by Vincent Ratford on 5/17/18.
//  Copyright © 2018 Vincent Ratford. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var Ruler: UIBarButtonItem!
    
    var dotNodes = [SCNNode]() // Array of dotNodes initialized to o, will place dotNodes here when added
    var textNode = SCNNode()
    var line = SCNPlane()  //using plane instead of line for geometry
    
    @IBAction func Restart(_ sender: UIBarButtonItem) {
        
        textNode.removeFromParentNode()
      
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
    
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "AR Ruler"
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
            
        }
        
}

    func addDot(at hitResult : ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {

            calculate()
        
        }
}

    func calculate () {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
//        print(start.position)
//        print(end.position)
//
        let distance = (sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)) * 39.3701 // convert meters to inches
        )
        
        let displayDistance = round(distance)
        
//      addLine(length: displayDistance, atPosition: start.position)  // Create a line from a plane
        
        updateText(text: "\(displayDistance) in.", atPosition: end.position)
        
//        print(displayDistance) // in meters
        
//        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        
        // The following section will align your text in the direction you're looking:
        
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)  // depth is 1.0
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode.removeFromParentNode()
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x - 0.005, position.y + 0.01, position.z)  // place text just to left of and above end point
        
        textNode.scale = SCNVector3(0.003, 0.003, 0.003)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        

    }
    
    //Mark: - Adding a line but can't figure out how to remove once added.  Also need to change orientation or
    func addLine(length: Float, atPosition startPosition: SCNVector3) {
        
        
        let length = length/39.3701 // convert to meters as plane dimesnions are in meters
        
        line = SCNPlane(width: CGFloat(length), height: 0.005)  // Plance that is long as the point being measured, not very tall
        
        line.firstMaterial?.diffuse.contents = UIColor.white
        
        let lineStart = SCNNode() // point in 3d space

        lineStart.position = SCNVector3(startPosition.x + length/2, startPosition.y, startPosition.z) // position of point

        lineStart.geometry = line // node has geometry of line

        sceneView.scene.rootNode.addChildNode(lineStart)  // place in sceneview

        sceneView.autoenablesDefaultLighting = true // adds light and shadows

        }
    
}
