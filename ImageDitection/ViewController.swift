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
import MapKit
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var savedLocation: UILabel!
    
    var count = 0
    var trainNode: SCNNode?
    var cartNode: SCNNode?
    var imageNodes = [SCNNode]()
    var tracking = [CLLocation]()
    var currentLatitude = Double()
    var currentLongitude = Double()
    var savedLatitude = Double()
    var savedLongitude = Double()
    let locationManager = CLLocationManager()
    var savedImages = [UIImage]()
    let trainScene = SCNScene(named: "art.scnassets/train.scn")
    let cartScene = SCNScene(named: "art.scnassets/shoppingCart.scn")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        trainNode = trainScene?.rootNode
        cartNode = cartScene?.rootNode
        checkLocationSearvice()
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
    
    // MARK: This is the save function
    @IBAction func save(_ sender: UIButton) {
        savedImages.append(self.sceneView.snapshot())
        savedLatitude = currentLatitude
        savedLongitude = currentLongitude
        DispatchQueue.main.async {
            self.savedLocation.text = "Saved Location: latitude-\(self.currentLatitude), longitude-\(self.currentLongitude)"
        }
        //UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if savedLatitude == currentLatitude && savedLongitude == currentLongitude {
            print("number222222")
            
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
                } else if imageAnchor.referenceImage.name == "traider" {
                    shapeNode = cartNode
                    shapeNode!.scale.x = shapeNode!.scale.x / 1.5
                    shapeNode!.scale.y = shapeNode!.scale.y / 1.5
                    shapeNode!.scale.z = shapeNode!.scale.z / 1.5
                    node.addChildNode(shapeNode!)
                }
                
                let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
                let repeatSpin = SCNAction.repeatForever(shapeSpin)
                shapeNode?.runAction(repeatSpin)
               // imageNodes.append(node)
                return node
            }
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 0.5)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            
            if distance < 0.10 {
                imageNodes[0].runAction(repeatSpin)
                imageNodes[1].runAction(repeatSpin)
            }
            
        }
    }
    
    // MARK: From this point is the code for locations
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationSearvice() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        tracking = locations
        
        currentLatitude = tracking.last!.coordinate.latitude
        currentLatitude = round(1000 * currentLatitude) / 1000
        currentLongitude = tracking.last!.coordinate.longitude
        currentLongitude = round(1000 * currentLongitude) / 1000
        latitude.text = "Latitude: \(currentLatitude)"
        longitude.text = "Longitude: \(currentLongitude)"
        trainNode = nil
        cartNode = nil
        trainNode = trainScene?.rootNode
        cartNode = cartScene?.rootNode
        print(count)
        count += 1
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}
