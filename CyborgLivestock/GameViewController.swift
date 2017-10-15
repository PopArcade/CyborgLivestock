//
//  GameViewController.swift
//  CyborgLivestock
//
//  Created by Ryan Poolos on 10/14/17.
//  Copyright © 2017 PopArcade. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var scnView: SCNView! {
        return view as! SCNView
    }

    override func loadView() {
        self.view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scnView.delegate = self
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        scene.rootNode.addChildNode(camera)

        // Pan the camera slowly forever
        let cameraPan = SCNAction.moveBy(x: 0, y: 0, z: -2, duration: 1)
        camera.runAction(.repeatForever(cameraPan))


        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: -10, y: 10, z: 0)
        camera.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        camera.addChildNode(ambientLightNode)

        // set the scene to the view
        scnView.scene = scene
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //==========================================================================
    // MARK: - SCNSceneRendererDelegate
    //==========================================================================

    var spawnTime: TimeInterval = 0
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime {
            spawnBuilding(z: camera.position.z - 20)
            spawnTime = time + 0.5
        }

        cleanUpBuildings()
    }

    //==========================================================================
    // MARK: - Spawn Ship
    //==========================================================================

    func spawnBuilding(z: Float) {
        let geometry = SCNBox(width: .random(upperBound: 4) + 1, height: .random(upperBound: 12) + 1, length: .random(upperBound: 4) + 1, chamferRadius: 0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(hue: CGFloat(arc4random_uniform(355))/355.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)

        geometry.materials = [material]

        let node = SCNNode()
        node.geometry = geometry

        node.position.z = z
        node.position.x = .random(upperBound: 12) - 6.0

        scnView.scene?.rootNode.addChildNode(node)
    }

    func cleanUpBuildings() {
        for node in scnView.scene!.rootNode.childNodes {
            if node === camera {
                continue
            }

            if camera.position.z < node.position.z, !scnView.isNode(node, insideFrustumOf: camera) {
                node.removeFromParentNode()
            }
        }
    }

    //==========================================================================
    // MARK: - Camera
    //==========================================================================

    lazy var camera: SCNNode = {
        let node = SCNNode()
        node.camera = SCNCamera()

        node.position = SCNVector3(x: 0, y: 25, z: 0)

        // rotate the camera to face down
        node.eulerAngles = SCNVector3(-CGFloat.pi / 2, 0, 0)

        return node
    }()
}
