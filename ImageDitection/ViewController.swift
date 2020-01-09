//
//  ViewController.swift
//  ImageDitection
//
//  Created by Edward O'Neill on 1/8/20.
//  Copyright © 2020 Edward O'Neill. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var trainNode: SCNNode?
    var cartNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let trainScene = SCNScene(named: "art.scnassets/train.scn")
        let cartScene = SCNScene(named: "art.scnassets/shoppingCart.scn")
        trainNode = trainScene?.rootNode
        cartNode = cartScene?.rootNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Test Cards", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.7)
            plane.cornerRadius = 0.003
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            var shapeNode: SCNNode?
            if imageAnchor.referenceImage.name == "Metro" {
                shapeNode = trainNode
                shapeNode!.scale.x = shapeNode!.scale.x / 5
                shapeNode!.scale.y = shapeNode!.scale.y / 5
                shapeNode!.scale.z = shapeNode!.scale.z / 5
                node.addChildNode(shapeNode!)
            } else {
                shapeNode = cartNode
                shapeNode!.scale.x = shapeNode!.scale.x / 1.5
                shapeNode!.scale.y = shapeNode!.scale.y / 1.5
                shapeNode!.scale.z = shapeNode!.scale.z / 1.5
                node.addChildNode(shapeNode!)
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
        }
        
        return node
    }
}
