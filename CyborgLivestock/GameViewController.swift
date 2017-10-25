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
import CoreMotion

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    let motionManager = CMMotionManager()

    var scnView: SCNView! {
        return view as! SCNView
    }

    override func loadView() {
        self.view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        motionManager.startAccelerometerUpdates()

        scnView.delegate = self
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        scene.rootNode.addChildNode(camera)

        // Pan the camera slowly forever
        let cameraPan = SCNAction.moveBy(x: 0, y: 0, z: -4, duration: 1)
        camera.runAction(.repeatForever(cameraPan))
        player.runAction(.repeatForever(cameraPan))

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

        scene.rootNode.addChildNode(player)

        scene.physicsWorld.contactDelegate = self

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
        spawnBullet()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //==========================================================================
    // MARK: - SCNSceneRendererDelegate
    //==========================================================================

    var buildingSpawnTime: TimeInterval = 0
    var enemySpawnTime: TimeInterval = 0
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > buildingSpawnTime {
            spawnBuilding(z: camera.position.z - 20)
            buildingSpawnTime = time + 0.5
        }

        if time > enemySpawnTime {
            spawnEnemy(z: camera.position.z - 20)
            enemySpawnTime = time + 1.0
        }

        cleanUpBuildings()

        if let accelerometerData = motionManager.accelerometerData {
            player.position.x += Float(accelerometerData.acceleration.x / 5)
            player.position.x = max(player.position.x, -3)
            player.position.x = min(player.position.x, 3)

            player.eulerAngles.z -= Float(accelerometerData.acceleration.x / 5)
            player.eulerAngles.z = max(player.eulerAngles.z, -0.5)
            player.eulerAngles.z = min(player.eulerAngles.z, 0.5)
        }
    }

    //==========================================================================
    // MARK: - Physics
    //==========================================================================

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        DispatchQueue.main.async {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
        }
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

        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: node, options: nil))
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.contactTestBitMask = 1

        scnView.scene?.rootNode.addChildNode(node)
    }

    func spawnEnemy(z: Float) {
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white

        geometry.materials = [material]

        let node = SCNNode()
        node.geometry = geometry

        node.position.z = z
        node.position.y = 15
        node.position.x = .random(upperBound: 6) - 3.0

        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: node, options: nil))
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.contactTestBitMask = 1

        scnView.scene?.rootNode.addChildNode(node)

        let spin = SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 1)
        node.runAction(.repeatForever(spin))
    }

    func spawnBullet() {
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 1)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red

        node.geometry?.materials = [material]

        node.position = player.position

        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: node, options: nil))

        scnView.scene?.rootNode.addChildNode(node)

        let move = SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1.0)
        let remove = SCNAction.removeFromParentNode()
        node.runAction(.sequence([move, remove]))
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
    // MARK: - Player
    //==========================================================================

    lazy var player: SCNNode = {
        let node = SCNNode()
        node.geometry = SCNBox(width: 1, height: 0.5, length: 1.5, chamferRadius: 0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white

        node.geometry?.materials = [material]

        node.position = SCNVector3(x: 0, y: 15, z: 5)

        return node
    }()

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
