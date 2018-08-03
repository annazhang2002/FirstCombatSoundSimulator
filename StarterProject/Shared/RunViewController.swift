//
//  runViewController.swift
//  firstCombatSoundSimulator
//
//  Created by student on 7/24/18.
//  Copyright © 2018 Anna Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MetaWear

class RunViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    var timer = Timer()
    var seconds = 15
    
    @IBOutlet weak var instructLabel: UILabel!
    var scenario: Int = 0
    var soundArray : [String] = []
    
    var optionsViewController: OptionsViewController?
    
    var pointArr: [CGPoint] = []
    
    @IBOutlet weak var stopButton: UIButton!
    /*
    @IBOutlet weak var coordinateLabel1: UILabel!
    @IBOutlet weak var coordinateLabel2: UILabel!
    
    var labelArr: [UILabel] = []
    
    func updateLabels(){
        for i in 0..<labelArr.count {
            print("text changed")
            let point = pointArr[i]
            labelArr[i].text = String("x:\(point.x),y:\(point.y)")
        }
    }
    */
    
    
    func sendScenario(scene: Int) {
        self.scenario = scene
        print("Scenario: " + String(scenario))
    }
    
    var playSoundsController: PlaySoundsController!
    
    @IBOutlet weak var deviceStatus: UILabel!
    
    let PI : Double = 3.14159265359
    
    var device: MBLMetaWear!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
         device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
         device.connectAsync().success { _ in
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            //NSLog("We are connected")
         }
        loadSounds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPressed(stopButton)
        //disconnect the sensors when the view disappears
        device.removeObserver(self, forKeyPath: "state")
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
        device.disconnectAsync()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            switch (self.device.state) {
            case .connected:
                self.deviceStatus.text = "Connected";
                self.device.sensorFusion?.mode = MBLSensorFusionMode.imuPlus
                print("connected")
                
            case .connecting:
                self.deviceStatus.text = "Connecting";
                print("connecting")
            case .disconnected:
                self.deviceStatus.text = "Disconnected";
                print("Disconnected")
            case .disconnecting:
                self.deviceStatus.text = "Disconnecting";
                print("Disconnecting")
            case .discovery:
                self.deviceStatus.text = "Discovery";
                print("Discovery")
            }
        }
    }
    
    func getFusionValues(obj: MBLEulerAngleData){
        /*
        let xS =  String(format: "%.02f", (obj.p))
        let yS =  String(format: "%.02f", (obj.y))
        let zS =  String(format: "%.02f", (obj.r))
        
        let x = radians((obj.p * -1) + 90)
        let y = radians(abs(365 - obj.y))
        let z = radians(obj.r)
        
        print("X: " + String(x))
        print("Y: " + String(y))
        print("Z: " + String(z))
 */
        playSoundsController?.updateAngularOrientation(Float(obj.h), Float(obj.p), Float(obj.r))
        
        // Send OSC here
    }
    
    func radians(_ degree: Double) -> Double {
        return ( PI/180 * degree)
    }
    func degrees(_ radian: Double) -> Double {
        return (180 * radian / PI)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background image
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo3.jpg")!)
        
        self.view.backgroundColor = UIColor.white
        let screenSize: CGRect = UIScreen.main.bounds
        let bgImage = UIImageView(image: UIImage(named: "star.jpg"))
        bgImage.center = CGPoint(x: self.view.bounds.size.width / 2,y: self.view.bounds.size.height / 2)
        bgImage.transform = CGAffineTransform(scaleX: screenSize.width / 768, y: screenSize.height / 1024)
        self.view.addSubview(bgImage)
        bgImage.layer.zPosition = 0
        
        stopButton.layer.zPosition = 1
        startButton.layer.zPosition = 1
        instructLabel.layer.zPosition = 1
        deviceStatus.layer.zPosition = 1
        
        startButton.layer.cornerRadius = 20
        stopButton.layer.cornerRadius = 20
        
        if scenario == 0{
            /*
            labelArr = [coordinateLabel1, coordinateLabel2]
            print("labelArr count: \(labelArr.count)")
            print("pointArr count: \(pointArr.count)")
            
            for i in 0..<labelArr.count {
                print("text changed")
                let point = pointArr[i]
                labelArr[i].text = String("x:\(Int(point.x)),y:\(Int(point.y))")
            }
            */
        }
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        while self.device.state != .connected {
            print("not connected yet")
        }
        device.sensorFusion?.eulerAngle.startNotificationsAsync { (obj, error) in
            self.getFusionValues(obj: obj!)
            }.success { result in
                print("Successfully subscribed")
            }.failure { error in
                print("Error on subscribe: \(error)")
        }
        
        //plays the sounds in the array
        
        for sound in soundArray.enumerated() {
            if (playSoundsController.isUsed(index: sound.offset)).boolValue {
                playSoundsController.play(index: sound.offset)
            }
        }
        
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        
        device.sensorFusion?.eulerAngle.stopNotificationsAsync().success { result in
            print("Successfully unsubscribed")
            }.failure { error in
                print("Error on unsubscribe: \(error)")
        }
        
        //plays the sounds in the array
        for sound in soundArray.enumerated() {
            playSoundsController.stop(index: sound.offset)
        }
        
    }
    
    
    func loadSounds() {
        
        /* sounds
         1)* 0.wav : AK47
         2)* 1.wav : Explosion 2
         3)* 2.wav : Helicopter 2
         4)* 3.wav : Sniper Rifle
         5)* 4.wav : Tank
         * 5.wav : Grenade Launcher
         * 6.wav : Machine Gun 3
         * 7.wav : Overall Battle ------ place at the origin in each scenario
         * 8.wav : Shotgun
         * 9.wav : Explosion 1
         * 10.wav : Helicopter Flyby
         * 11.wav : Advance
         * 12.wav : Cease fire
         * 13.wav : Cover fire
         * 14.wav : disengage
         * 15.wav : engage
         * 16.wav : establish perimeter
         * 17.wav : fall back
         * 18.wav : fire at will
         * 19.wav : hold position
         * 20.wav : move out
         * 21.wav : move up
         * 22.wav : open fire
         * 23.wav : stay put
         * 24.wav : stop
         */
        
        //adds the sounds to the array and updates positions
        for i in 0...10 {
            soundArray.append(String(i) + ".wav")
        }
        
        
        //initializing the player with the soundArray files
        playSoundsController = PlaySoundsController(files: soundArray)
        
        //updates the position of the sound based on the scenario
        switch (scenario){
        case 1:
            playSoundsController.updatePosition(index: 0, position: AVAudio3DPoint(x: 50, y: -20, z: 10))
            playSoundsController.updatePosition(index: 6, position: AVAudio3DPoint(x: -50, y: 40, z: 0))
            playSoundsController.updatePosition(index: 9, position: AVAudio3DPoint(x: -25, y: 25, z: -10))
        case 2:
            playSoundsController.updatePosition(index: 3, position: AVAudio3DPoint(x: 50, y: 30, z: 10))
            playSoundsController.updatePosition(index: 5, position: AVAudio3DPoint(x: -25, y: 25, z: 20))
            playSoundsController.updatePosition(index: 8, position: AVAudio3DPoint(x: -50, y: 25, z: -15))
            
        case 0:
            for i in 0..<pointArr.count {
                let point = pointArr[i]
                playSoundsController.updatePosition(index: i, position: AVAudio3DPoint(x: Float(point.x), y: Float(point.y), z: 0))
                if (point.y > 50) {
                    playSoundsController.updateVolume(index: i, volume: 0.0)
                }
            }
            
            
        default:
            print("Scenario not found")
        }
        //print("sound positions updated")
        
        
        //has the overall battle sound always play quietly in each scenario
        //playSoundsController?.updatePosition(index: 11, position: AVAudio3DPoint(x: 0, y: 0, z: 0))
        //playSoundsController?.updateVolume(index: 11, volume: 0.2)
        
    }
    
}
