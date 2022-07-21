//
//  ViewController.swift
//  chestCompressionSkill
//
//  Created by 2022 Summer Internship on 7/6/22.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import RealityKit //not rly needed
import CreateML // this too

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // VARIABLES
    var goodCCCt = 0 // # of good CC during time (30 sec) based on pressure
    var goodLocationCt = 0 // # of times they pressed in right area (between nipple lines)
//    var pressureCt = 0 // # of times of good pressure..not needed??
    var totalTouchCt = 0 // # of times of attemped CC
    var speedTouchCt = 0 // # of times of attemped CC to track speed
    var rad = 0.0 // total radius for multiple touches
    var countdownCt = 3 // starting number for countdown
    var song: AVAudioPlayer! // song
    var isTouch = false
    var bodyPlace = true // if we can put a body down
    var bodyArray = [SCNNode]()
    
//    let radTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRad), userInfo: nil, repeats: true) // timer to update majRadius
    //overall timer
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var speedButton: UIButton!
    var timer = Timer()
    @objc func timerAction() {
        if speedTouchCt < 5 {
            //too slow
            speedButton.backgroundColor = UIColor.yellow
//            speedButton.tintColor = UIColor.yellow
        } else if speedTouchCt > 6 {
            // too fast
            speedButton.backgroundColor = UIColor.red
//            speedButton.tintColor = UIColor.red
        } else {
            //good
            speedButton.backgroundColor = UIColor.green
//            speedButton.tintColor = UIColor.green
        }
        speedTouchCt = 0
    }
    
    @IBOutlet weak var pressureBar: UIProgressView!
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        //Go back to skills screen
    }
    @IBAction func startButton(_ sender: UIButton) {
        // When start button pressed:
        //set isTouch to true so touch is counted
        isTouch = true
        // 1. Music start playing
        let url = Bundle.main.url(forResource: "CPRmusic", withExtension: "mp3")
        song = try! AVAudioPlayer(contentsOf: url!)
        song.play()
        // 2. starts good CCs at 0
        goodCCCt = 0
        // 3. starts counting good location --> do we even need location?
        // 4. start 3 second countdown
        let timer1 = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            //code to display 3..2..1..go
            self.countdownLabel.textColor = UIColor.black
            self.countdownLabel.text = String(self.countdownCt)
            if self.countdownCt == 0 {
                self.countdownLabel.text = "go"
                self.countdownCt -= 1
            } else if self.countdownCt == -1 {
                timer.invalidate()
                self.countdownLabel.text?.removeAll()
            } else {
                self.countdownCt -= 1
            }
            
        }
        let timer3 = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
            //starts speed timer
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        }
        // 5. start full countdown
        let timer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            //goes to stats screen, 33.2 seconds
            self.performSegue(withIdentifier: "goToCCStats", sender: self)
            self.song.stop()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToCCStats" {
                let destinationVC = segue.destination as! CCStatsViewController
                destinationVC.goodCCCt = self.goodCCCt
                destinationVC.totalTouchCt = self.totalTouchCt
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // for lighting
        sceneView.autoenablesDefaultLighting = true
        
        // for troubleshooting
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Rotates pressure bar to vertical and shifts to left side of screen
        pressureBar.transform = CGAffineTransform(rotationAngle: .pi * 3 / 2).translatedBy(x: 0, y: -150)
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        // sets speed button color first
        speedButton.backgroundColor = UIColor.green
        //rounds corner of speed button
        speedButton.layer.cornerRadius = 5
        
//        let bookModel = try! ModelEntity.load(named: "Booktest1")
//        let anchorEntity = AnchorEntity(plane: .horizontal)
//        anchorEntity.addChild(bookModel)
//        sceneView.scene
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // FOR BODY PLACEMENT GOING DOWN
        if bodyPlace == true {
            if (!bodyArray.isEmpty) {
                bodyArray.removeAll()
            }
            if let touch = touches.first {
                let touchLocation = touch.location(in: sceneView)
                let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
                if let hitResult = results.first {
                    let bodyScene = SCNScene(named: "art.scnassets/down.scn")! //down.scn, AnyConv.com__manbody copy.scn
                    if let bodyNode = bodyScene.rootNode.childNode(withName: "please", recursively: true) { // please, Object-1
                        bodyNode.position = SCNVector3(
                            x: hitResult.worldTransform.columns.3.x,
                            y: hitResult.worldTransform.columns.3.y - (bodyNode.boundingSphere.radius / 2),
                            z: hitResult.worldTransform.columns.3.z
                        )
                        sceneView.scene.rootNode.addChildNode(bodyNode)
                        bodyArray.append(bodyNode)
                    }
                }
            }
            bodyPlace = false
        }
        // adds one to total touch for frequency
        if isTouch == true {
            totalTouchCt += 1
            speedTouchCt += 1
        }
        isTouch = false
        // progress bar updates
        // animation going down plays
        // MULTIPLE TOUCHES
        for touche in touches {
//            print(touche.majorRadius)
            rad = rad + touche.majorRadius
        }
        // to add changes to the multiple fingers
//        if let touch = touches.first {
//            rad = touch.majorRadius
//        }
        pressureBar.progress = Float(rad/150)
        //progressBar COLOR
        if rad > 60 { // 60 is just a temp number
            pressureBar.tintColor = UIColor.green
        } else {
            pressureBar.tintColor = UIColor.yellow
        }
        // pressureBar.progress = Float(touch.majorRadius/150)
        // 2. starts counting good CCs
        if pressureBar.progress > 0.5 { //0.6 is 60%, just a stand in value
            goodCCCt += 1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // animation recoil plays
        // progress bar goes down to 0.0
        pressureBar.progress = 0.0
        // radius is reset to 0
        rad = 0.0
        // so it can start to rerecognize touch
        isTouch = true
        //FOR ANIMATION GOING UP --> maybe try rotating body
        if bodyPlace == false {
            if (!bodyArray.isEmpty) {
                bodyArray.removeAll()
            }
            if let touch = touches.first {
                let touchLocation = touch.location(in: sceneView)
                let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
                if let hitResult = results.first {
                    let bodyScene = SCNScene(named: "art.scnassets/down.scn")! //down.scn, AnyConv.com__manbody copy.scn, success copy.scn
                    if let bodyNode = bodyScene.rootNode.childNode(withName: "please", recursively: true) { // please, Object-1, untitled_2
                        bodyNode.position = SCNVector3(
                            x: hitResult.worldTransform.columns.3.x,
                            y: hitResult.worldTransform.columns.3.y - (bodyNode.boundingSphere.radius / 2),
                            z: hitResult.worldTransform.columns.3.z
                        )
                        sceneView.scene.rootNode.addChildNode(bodyNode)
                    }
                }
            }
            bodyPlace = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    //for the plane detection
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            if anchor is ARPlaneAnchor {
                
                print("plane detected")
                
                let planeAnchor = anchor as! ARPlaneAnchor

                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
                let planeNode = SCNNode()

                planeNode.geometry = plane
                planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
                
                node.addChildNode(planeNode)
                
            } else {
                return
            }
    }

}
