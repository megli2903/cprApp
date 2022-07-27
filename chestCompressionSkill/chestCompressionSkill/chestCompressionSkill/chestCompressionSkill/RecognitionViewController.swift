//
//  RecognitionViewController.swift
//  chestCompressionSkill
//
//  Created by 2022 Summer Internship on 7/12/22.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class RecognitionViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("is shaking")
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                let directionsScene = SCNScene(named: "art.scnassets/flyer1 copy.scn")! //down.scn, AnyConv.com__manbody copy.scn, flyer1 copy.scn
                if let directionsNode = directionsScene.rootNode.childNode(withName: "flyer1", recursively: true) { // please, Object-1
                    directionsNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y - (directionsNode.boundingSphere.radius / 2),
                        z: hitResult.worldTransform.columns.3.z
                    )
                    //directionsNode.rotation = SCNVector4(0, 270, 0, 0) //x,y,z,w
                    sceneView.scene.rootNode.addChildNode(directionsNode)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            if anchor is ARPlaneAnchor {
                
                print("plane detected")
                
                let planeAnchor = anchor as! ARPlaneAnchor

                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
                let planeNode = SCNNode()

                planeNode.geometry = plane
                planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
                //this shows the plane
                node.addChildNode(planeNode)
                
            } else {
                return
            }
    }
}
