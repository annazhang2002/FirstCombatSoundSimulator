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
    
    var scenario: Int = 0
    var soundArray : [String] = []
    
    var optionsViewController: OptionsViewController?
    
    var pointArr: [CGPoint] = []
    
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
            NSLog("We are connected")
         }
        loadSounds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        let xS =  String(format: "%.02f", (obj.p))
        let yS =  String(format: "%.02f", (obj.y))
        let zS =  String(format: "%.02f", (obj.r))
        
        let x = radians((obj.p * -1) + 90)
        let y = radians(abs(365 - obj.y))
        let z = radians(obj.r)
        
        print("X: " + String(x))
        print("Y: " + String(y))
        print("Z: " + String(z))
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
        // Do any additional setup after loading the view, typically from a nib.
        
        //set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "camo")!)
        
        if scenario == 0{
            labelArr = [coordinateLabel1, coordinateLabel2]
            print("labelArr count: \(labelArr.count)")
            print("pointArr count: \(pointArr.count)")
            for i in 0..<labelArr.count {
                print("text changed")
                let point = pointArr[i]
                labelArr[i].text = String("x:\(Int(point.x)),y:\(Int(point.y))")
            }
        }
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        device.sensorFusion?.eulerAngle.startNotificationsAsync { (obj, error) in
            //uncomment the next line to start retrieving values
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
         * 0.wav : AK47
         * 1.wav : Explosion 2
         * 2.wav : Explosion 1
         * 3.wav : Grenade Launcher
         * 4.wav : Helicopter 2
         * 5.wav : Helicopter Flyby
         * 6.wav : Machine Gun 3
         * 7.wav : Overall Battle ------ place at the origin in each scenario
         * 8.wav : Shotgun
         * 9.wav : Sniper Rifle
         * 10.wav : Tank
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
            playSoundsController.updatePosition(index: 0, position: AVAudio3DPoint(x: 100, y: 100, z: 0))
            
        case 2:
            playSoundsController.updatePosition(index: 0, position: AVAudio3DPoint(x: 50, y: 50, z: 50))
            
        case 0:
            for i in 0..<pointArr.count {
                let point = pointArr[i]
                playSoundsController.updatePosition(index: i, position: AVAudio3DPoint(x: Float(point.x), y: Float(point.y), z: 0))
            }
            
            
        default:
            print("Scenario not found")
        }
        print("sound positions updated")
        
        
        //has the overall battle sound always play quietly in each scenario
        //playSoundsController?.updatePosition(index: 11, position: AVAudio3DPoint(x: 0, y: 0, z: 0))
        //playSoundsController?.updateVolume(index: 11, volume: 0.2)
        
    }
    
}
